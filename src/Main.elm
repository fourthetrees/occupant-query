import Types exposing (..)
import Html exposing (Html)
import Utilities as Utils
import Interface as Iface
import Components as Comp
import Dict exposing (Dict)
import Comms


main = Html.programWithFlags
  { init = init
  , update = update
  , subscriptions = subscriptions
  , view = view
  }


type alias Flags =
  { srvr : String
  , tick : Int
  , mode : Int
  }


parse_flags : Flags -> Config
parse_flags flags =
  let
    conf : ( Mode -> Config )
    conf = Config flags.srvr flags.tick
  in
    if flags.mode < 1 then
      conf Form
    else conf Kiosk


init : Flags -> ( Model , Cmd Msg )
init flags =
  let
    pgrm = Init
    conf = parse_flags flags 
  in
      ( { pgrm = pgrm, conf = conf }
      , Comms.pull_survey conf     )


update : Msg -> Model -> ( Model , Cmd Msg )
update msg model =
  case model.pgrm of
    -- if program is initializing, await server comms.
    Init -> 
      case msg of
        -- response from server.
        Recv rsp ->
          let
            (pgrm,conf) = case Comms.process_rsp Nothing model.conf rsp of
              Just (pgrm,conf) -> ( Run pgrm , conf )

              Nothing -> ( Init , model.conf )
          in
            ( { model | pgrm = pgrm , conf = conf }
            , Cmd.none              )

        -- all other messages are errors.
        _ ->
          let _ = Debug.log "unexpected msg" msg
          in ( model, Cmd.none )

    -- if program is running, handle all `Msg` types.
    Run pgrm ->
      case msg of
        Recv rsp ->
          let
            (pgrm,conf) = case Comms.process_rsp (Just pgrm) model.conf rsp of
              Just (pgrm,model.conf)-> ( Run pgrm , model.conf )
              Nothing -> ( model.pgrm , model.conf )
          in
            ( { model | pgrm = pgrm, conf = conf }
            , Cmd.none )

        User input ->
          let
            (updated,cmd) = Iface.apply_input pgrm input
          in
            ( { model | pgrm = Run updated }
            , cmd )

        Save response ->
          let
            updated = Utils.add_response response pgrm
            push = Comms.push_archive model.conf
          in
            ( { model | pgrm = Run updated }
            , push updated.arch )

    -- if program is finished, do nothing.
    Fin ->
      ( model , Cmd.none )




subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


view : Model -> Html Msg
view { pgrm, conf } =
  case pgrm of
    Init ->
      Comp.splash "loading..."

    Run pgrm ->
      case conf.mode of
        Kiosk ->
          Iface.render_kiosk pgrm

        Form ->
          Iface.render_form pgrm
 
    Fin ->
      Comp.splash "Thank You!"



