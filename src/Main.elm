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
    User input ->
      case model.pgrm of
        Run pgrm ->
          let
            (pgrm,cmd) = Iface.apply_input input pgrm
          in
            ( { model | pgrm = Run pgrm }
            , cmd )

        _ ->
          let _ = Debug.log "invalid input" input
          in ( model, Cmd.none )

    -- TODO: Refactor to two top-lvl `Msg` types s.t. we can
    -- separate Comms from stateful events.    
    
    Save response ->
      let
        pgrm = Utils.add_response model.pgrm response
      in
        ( { model | pgrm = pgrm }
        , Comms.push_archive pgrm.arch )

    Recv rslt ->
      case rslt of
        Update (rslt) ->
          let
            pgrm = Comms.apply_update model.pgrm rslt
          in
            ( { model | pgrm = pgrm }
            , Cmd.none )

        Upload (rslt) ->
          let
            pgrm = Comms.assess_upload model.pgrm rslt
          in
            ( { model | pgrm = pgrm }
            , Cmd.none )


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

        Form ->
          Iface.render_form conf pgrm
 
    Fin ->
      Comp.splash "Thank You!"



