module Interface exposing (..)

import Html exposing (Html)
import Types exposing (..)
import Dict exposing (Dict)
import Components exposing (..)


render_kiosk : Config -> Pgrm -> Html Msg
render_kiosk conf pgrm =
  splash "~kiosk placeholder~"


render_form : Config -> Pgrm -> Html Msg
render_form conf pgrm =
  splash "~form placeholder~"


-- apply user input to the program state.
apply_input : Input -> Pgrm -> ( Pgrm , Cmd Msg )
apply_input input pgrm =
  case input of
    Select selection ->
      let
        pgrm = Utils.insert_selection selection model.pgrm
      in
        ( pgrm , Cmd.none )

    Submit ->
      let
        (pgrm,cmd) =
          case Utils.submit_session model.pgrm of
            Ok (pgrm,cmd) -> (pgrm,cmd)
            Err (_) ->
              ( Debug.log "invalid submit event" model.pgrm
              , Cmd.none )
      in
        ( pgrm, cmd )


