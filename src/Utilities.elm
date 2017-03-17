module Utilities exposing (..)

-- LOCAL DEPENDENCIES --
import Types exposing (..)
import Sugar exposing (..)

-- ELM-PACKAGE DEPENDENCIES --
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as JE
import Json.Decode as JD
import Debug
import Dict
import Task
import Http
import Time

-- MISC --

-- Rotate a list forward by one.
rotate_list : List a -> List a
rotate_list list =
  let
    lhead = case ( List.head list ) of
      Just h  -> [ h ]
      Nothing -> []
    ltail = case ( List.tail list ) of
      Just t  ->  t
      Nothing -> []
  in
    ltail ++ lhead

-- Send any number of Messages as Cmg Msg type.
send_signal : List Msg -> Cmd Msg
send_signal messages =
  List.map
    (\msg -> Task.perform (\_-> msg) ( Task.succeed 0 ) )
    messages
  |> Cmd.batch

-- Generates a timestamped archive object for the vote in question.
timestamp : Selections -> Cmd Msg
timestamp selections =
  let
    entry : ( Timestamp -> Entry )
    entry = (\time ->
      { selections = selections
      , time       = time
      } )
  in
    Task.perform
      (\ time -> Save ( entry time ) )
      Time.now

-- Check if all query options have been filled out.
is_filled : Selections -> Queries -> Bool
is_filled selections queries =
  let
    s_ids  = Dict.keys selections
    q_ids  = List.map (\q -> q.queryID ) queries
    not_in = (\list elem ->
      not ( List.any (\i -> i == elem) list )
      )
  in
    if List.any ( not_in s_ids ) q_ids then
      False
    else
      True

-- Handle an instance of the 'Submit' button being pressed.
handle_submission : Model -> ( Model, Cmd Msg )
handle_submission model =
  let
    selections = model.selections
  in
    ( { model | page = SplashPage
      , selections = Dict.empty
      , is_filled  = False }
    , timestamp selections )

-- Pass selection events to their appropriate handlers.
handle_selection : Model -> QueryID -> Vote -> ( Model, Cmd Msg )
handle_selection model queryID vote =
  case model.paradigm of
    Form ->
      form_select model queryID vote
    Kiosk ->
      kiosk_select model queryID vote

-- Record a form selection event.
-- Used for multiple-selection queries.
form_select : Model -> QueryID -> Vote -> ( Model, Cmd Msg )
form_select model queryID vote =
  let
    queries    = model.queries
    selections = Dict.insert
      queryID
      vote
      model.selections
  in
    ( { model | selections = selections
      , is_filled  = is_filled selections queries }
    , Cmd.none )

-- Record a kiosk selection event.
-- Used for single-selection queries.
kiosk_select : Model -> QueryID -> Vote -> ( Model, Cmd Msg )
kiosk_select model queryID vote =
  let
    queries    = model.queries
    selections = Dict.insert
      queryID
      vote
      model.selections
  in
    ( { model | selections = selections
      , queries = rotate_list queries }
    , send_signal [ Submit ] )

-- Save an entry to the archive & trigger and upload attempt.
handle_save : Model -> Entry -> ( Model, Cmd Msg )
handle_save model entry =
  let
    new_arch   = model.archive ++ [ entry ]
    cmd_upload = send_signal [ Upload ]
  in
    ( { model | archive = new_arch }
      , cmd_upload )

-- /

-- COMMUNICATION --

-- Evaluates the model and calls the attempt_upload function if needed.
handle_upload : Model -> ( Model, Cmd Msg )
handle_upload model =
  let
    archive = model.archive
    uploads = model.uploads
    server  = model.config.server_address
    empty   = (\l -> List.isEmpty l)
  in
    if empty archive || not (empty uploads) then
      ( model, Cmd.none )
    else
      ( { model |
          archive = [] ,
          uploads = archive    }
        , attempt_upload server archive )

-- Attempts to upload an Archive as a Server as JSON encoded POST data.
attempt_upload : Server -> Archive -> Cmd Msg
attempt_upload server archive =
  let
    jdata : JE.Value
    jdata = arch_to_json archive
  in
    json_post server jdata
      |> Http.send Recieve

-- Converts an Archive to a JSON encoded Value.
arch_to_json : Archive -> JE.Value
arch_to_json archive =
  let
    from_selections = (\ sel -> JE.object
      ( List.map
        (\ (qid,vote) -> (qid,JE.string vote) )
        ( Dict.toList sel ) ) )
    from_time  = (\ time -> JE.float time )
    from_entry = (\ ft fs entry ->
      JE.list [ ft entry.time , fs entry.selections ]
      )
  in
    JE.list ( List.map
      ( from_entry from_time from_selections )
      archive
      )

-- custom http post request cuz Http.post suuuuuucks
json_post : String ->  JE.Value -> Http.Request ( Dict.Dict String String )
json_post url jdata = Http.request
  { method          = "POST"
  , headers         = [ Http.header "Content-Type" "application/json" ]
  , url             = url
  , body            = Http.stringBody "application/json" (JE.encode 0 jdata)
  , expect          = Http.expectJson ( JD.dict JD.string )
  , timeout         = Just ( Time.second * 6 )
  , withCredentials = False
  }

-- Executes appropriate model updates based on an http response.
handle_response : Model -> Comms -> ( Model, Cmd Msg )
handle_response model comms =
  case comms of
    -- Deletes values which have been uploaded.
    Ok ( dict ) ->
      ( { model | uploads = [] }
      , Cmd.none )
    -- Re-adds failed uplaods to main archive.
    Err ( error ) ->
      let
        _        = Debug.log "Error: " error
        new_arch = model.archive ++ model.uploads
      in
        ( { model |
            archive = new_arch ,
            uploads = []       }
          , Cmd.none )


-- TODO
-- update_model : Model -> Dict.Dict String String -> Model


-- Updates Deplyoment from JSON encoded String.
update_deployment : Deployment -> String -> Deployment
update_deployment deployment json =
  let
    jparse = (\ d s ->
      Result.toMaybe ( JD.decodeString d s )
      )
    src = jparse ( JD.dict JD.string ) json
    new_queries = src
      ||~ Dict.get "queries"
      ||~ jparse ( JD.list JD.string )
      |~ List.filterMap decode_query
    new_config = src
      ||~ Dict.get "config"
      ||~ decode_config
  in
    new_queries
      |~ Deployment
      ||~ (\ d -> new_config |~ d )
      /~ deployment

-- Attempts to decode a JSON string into a Query object.
decode_query : String -> Maybe Query
decode_query json =
  let
    src = Result.toMaybe ( JD.decodeString ( JD.dict JD.string ) json )
  in
    src
      |~ (\ s -> ( s, Query ) )
      ||~ parse "question" JD.string
      ||~ parse "responses" ( JD.list JD.string )
      ||~ parse "queryID"  JD.string
      |~ (\ ( s, c ) -> c )

-- Attempts to decode a JSON string into a Config object
decode_config : String -> Maybe Config
decode_config json =
  let
    src = Result.toMaybe ( JD.decodeString ( JD.dict JD.string ) json )
  in
    src
      |~ (\ s -> ( s, Config ) )
      ||~ parse "splash_interval" JD.float
      ||~ parse "uplaod_interval" JD.float
      ||~ parse "server_address"  JD.string
      ||~ parse "splash_text"     JD.string
      ||~ parse "hard_query"      JD.bool
      |~ (\ ( s, c ) -> c )

-- Key -> Decoder -> ( Source, Accumulator ) -> Maybe ( Source, Accumulator )
parse : String -> JD.Decoder a -> ( Dict.Dict String String , ( a -> b ) ) -> Maybe ( Dict.Dict String String , b )
parse key decoder ( source , collector ) =
  let
    -- ( decoder -> value ) -> string -> maybe value
    decode : JD.Decoder a -> String -> Maybe a
    decode = (\ d v -> Result.toMaybe ( JD.decodeString d v ) )
  in
    Dict.get key source
    ||~ decode decoder
    |~ collector
    |~ (\ c -> ( source , c ) )

-- /


-- SUBSCRIPTIONS --

-- Generates a simple subscription.
subscribe : Msg -> Float -> Sub Msg
subscribe msg seconds =
  let
    sub_interval = Time.second * seconds
    message = always ( msg )
  in
    Time.every sub_interval message

-- /

-- VIEW --

build_queries : Model -> Html Msg
build_queries model =
  case model.paradigm of
    Form ->
      build_many_queries model
    Kiosk ->
      build_single_query model

build_single_query : Model -> Html Msg
build_single_query model =
  let
    qhead = List.head model.queries
  in
    case qhead of
      Just query ->
        div
          [ classList [ ( "query-page", True )] ]
          [ div [] [ make_query model query ]   ]
      Nothing ->
        build_txt_page "Query Data Unavailable"


-- CONTINUE HERE... NEED TO HANDLE SINGLE QUERY CASE YO!

build_many_queries : Model -> Html Msg
build_many_queries model =
  let
    questions =
      div [] ( List.map ( make_query model ) model.queries )
    submit =
      div [ classList [ ( "submit", True ) ] ]
        [ button
            [ onClick Submit
            , disabled ( not model.is_filled )
            , classList [ ( "submit-button", True ) ] ]
            [ text "Submit" ] ]
  in
    div
      [ classList [ ( "query-page", True )] ]
      [ questions , submit ]

-- Generates a div containing a question & its response buttons.
make_query : Model -> Query -> Html Msg
make_query model query =
  let
    question  = query.question
    responses = query.responses
    queryID   = query.queryID
  in
    div [ classList [ ( "query", True ) ] ]
      [ h1  [ classList [ ( "query-txt", True ) ] ] [ text question ]
      , div
        [ classList [ ( "responses", True ) ] ]
        ( List.map ( make_selector model queryID ) responses )
      ]

-- Generates a selection button.
make_selector : Model -> QueryID -> Vote -> Html Msg
make_selector model queryID vote =
  let
    selected = is_selected  model queryID vote
  in
    button
      [ onClick ( Select ( queryID, vote ) )
      , classList [ ( "selected", selected ) ] ]
      [ text vote ]




-- Check if a button instance is currently selected.
is_selected : Model -> QueryID -> Vote -> Bool
is_selected model queryID vote =
  let
    selection = Dict.get queryID model.selections
  in
    case selection of
      Just selection ->
        if vote == selection then
          True
        else False
      Nothing ->
        False


-- Build splash page.
build_txt_page : String -> Html Msg
build_txt_page txt =
  div []
    [ h1 [] [ text txt ] ]



-- /
