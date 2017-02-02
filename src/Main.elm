-- MULTIPAGE QUERY GENERATOR --
---- Produced on Behalf of CSBCD at the University of Hawaii at Manoa
---- Author: Forrest Marshall

-- LOCAL DEPENDENCIES --
import Types exposing (..)
import Utilities as Utils

-- ELM-PACKAG DEPENDENCIES --
import Html
import Dict


-- MAIN LOOP BOILERPLATE --
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- /


-- MODEL --

-- Deplyoment arg injected server-side by flask/jinja.
type alias Flags = Deployment
init : Flags -> ( Model, Cmd Msg )
init deployment =
  let
    model: Model
    model =
      { page    = QueryPage
      , queries = deployment.queries
      , config  = deployment.config
      , archive = []
      , uploads = []
      , splash  = deployment.splash
      , selections = Dict.empty
      , is_filled  = False
      , paradigm   = get_paradigm deployment
      }
  in
    (model, Cmd.none)

get_paradigm : Deployment -> Paradigm
get_paradigm deployment =
  let
    qcount = List.length deployment.queries
  in
    if qcount > 1 then
      SoftQuery
    else
      HardQuery

-- /


-- UPDATE --

-- Handles events & updates to the model.
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of

    -- Takes record a selection event.
    Select ( queryID, vote ) ->
      Utils.handle_selection model queryID vote

    -- Handle click of "Submit" button by user.
    Submit ->
      Utils.handle_submission model

    -- Saves a generated archive to model.
    Save entry ->
      Utils.handle_save model entry

    -- Return to standard query page.
    Resume ->
      ( { model | page = QueryPage }, Cmd.none )

    -- Triggers the uplaod handler.
    Upload ->
      Utils.handle_upload model

    -- Handles an http response.
    Recieve comms ->
      Utils.handle_response model comms


-- SUBSCRIPTIONS --


-- Generates subscriptions for time-dependent events.
subscriptions : Model -> Sub Msg
subscriptions model =
  case model.page of

    QueryPage ->
      let
        upload_interval = model.config.upload_interval
      in
        Utils.subscribe Upload upload_interval

    SplashPage ->
      let
        upload_interval = model.config.upload_interval
        splash_interval = model.config.splash_interval
      in
        Sub.batch
          [ Utils.subscribe Upload upload_interval
          , Utils.subscribe Resume splash_interval
          ]

    StaticPage ( _ ) ->
      Sub.none

-- /


-- VIEW --

-- Toggles between question page and splash page.
view : Model -> Html.Html Msg
view model =
  case model.page of

    QueryPage ->
      Utils.build_queries model

    SplashPage ->
      Utils.build_txt_page model.splash

    StaticPage txt ->
      Utils.build_txt_page txt

-- /
