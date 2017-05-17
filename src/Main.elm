import Types exposing (..)
import Html exposing (Html)
import Interface as Iface
import Components as Comp
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
  ( { pgrm = Nothing
    , conf =
      { srvr = ""
      , tick = 20
      , mode = Init
      }
    }
  , Comms.load_survey "" ) -- immediately request `Survey` data.


update : Msg -> Model -> ( Model , Cmd Msg )
update msg model =
  case msg of
    Set mode ->
      let
          conf = { model.conf | mode = mode }
      in
        ( { model | conf = conf }
        , Cmd.none )

    User input ->
      case input of
        Select selection ->
          let
            pgrm = Utils.handle_select selection model.pgrm
          in
            ( { model | pgrm = pgrm }
            , Cmd.none )

        Submit session ->
          let
            (pgrm,cmd) = Utils.handle_submit session model.pgrm
          in
            ( { model | pgrm = pgrm }
            , cmd )

    Save response ->
      let
        (pgrm,cmd) = Utils.handle_save response model.pgrm
      in
        ( { model | pgrm = pgrm }
        , cmd )
    
    Update comms ->
      Comms.handle_update model comms


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


view : Model -> Html Msg
view { pgrm, conf } =
  case pgrm of
    Init ->
      Comp.splash "loading..."

    Run pgrm ->
      case pgrm.mode of
        Kiosk ->
          Iface.render_kiosk conf pgrm

        Form survey ->
          Iface.render_form conf pgrm
 
    Fin ->
      Comp.splash "Thank You!"



