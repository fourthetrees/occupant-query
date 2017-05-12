import Types exposing (..)
import Html exposing (Html)
import Interface as Iface
import Dict exposing (Dict)
import Comms


main = Html.program
  { init = init
  , update = update
  , subscriptions = subscriptions
  , view = view
  }


init : ( Model , Cmd Msg )
init =
  ( { program = Init -- program is initializing.
    , session = Dict.empty   -- nothing in session yet.
    , archive = []   -- nothing in archive yet.
    }
  , Comms.load_survey ) -- immediately request `Survey` data.


update : Msg -> Model -> ( Model , Cmd Msg )
update msg model =
  case msg of
    Set state ->
      ( { model | program = state }
      , Cmd.none )

    User input ->
      Iface.handle_input model input

    Update comms ->
      Comms.handle_update model comms


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


view : Model -> Html Msg
view model =
  case model.program of
    Init ->
      Iface.splash "loading survey..."

    Kiosk survey ->
      Iface.render_kiosk model survey

    Form survey ->
      Iface.render_form model survey

    Fin ->
      Iface.splash "process complete."
