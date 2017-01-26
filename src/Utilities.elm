module Utilities exposing (..)

-- LOCAL DEPENDENCIES --
import Types exposing (..)

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

-- Record a selection event.
handle_selection : Model -> QueryID -> Vote -> ( Model, Cmd Msg )
handle_selection model queryID vote =
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
  let
    questions =
      div [] ( List.map ( mkQuery model ) model.queries )
    submit =
      div [ classList [ ( "submit", True ) ] ]
        [ button
            [ onClick Submit
            , disabled ( not model.is_filled )
            , classList [ ( "submit-button", True ) ] ]
            [ text "Submit" ] ]
  in
    div [] [ questions , submit ]

-- Generates a div containing a question & its response buttons.
mkQuery : Model -> Query -> Html Msg
mkQuery model query =
  let
    question  = query.question
    responses = query.responses
    queryID   = query.queryID
  in
    div
      [ classList [ ( "query", True ) ] ]
      [ h1  [classList [ ( "query-txt", True ) ]] [ text question ]
      , div
        [ classList [ ( "responses", True ) ] ]
        ( List.map ( mkSelector model queryID ) responses )
      ]

-- Generates a selection button.
mkSelector : Model -> QueryID -> Vote -> Html Msg
mkSelector model queryID vote =
  let
    selected = is_selected model queryID vote
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
build_splash : Splash -> Html Msg
build_splash splash =
  div []
    [ h1 [] [ text splash ] ]



-- /
