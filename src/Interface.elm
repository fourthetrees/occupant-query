module Interface exposing (..)

import Html exposing (Html)
import Types exposing (..)
import Dict exposing (Dict)
import Components exposing (..)
import Utilities as Utils

render_kiosk : Config -> Pgrm -> Html Msg
render_kiosk conf pgrm =
  splash "~kiosk placeholder~"


render_form : Config -> Pgrm -> Html Msg
render_form conf pgrm =
  splash "~form placeholder~"


-- apply user input to the program state.
apply_input : Pgrm -> Input -> ( Pgrm , Cmd Msg )
apply_input pgrm input =
  case input of
    Select selection ->
      let
        updated = Utils.insert_selection selection pgrm
      in
        ( updated , Cmd.none )

    Submit ->
      let
        (updated,cmd) =
          case Utils.submit_session pgrm of
            Ok (pgrm,cmd) -> (pgrm,cmd)
            Err (_) ->
              ( Debug.log "invalid submit event" pgrm
              , Cmd.none )
      in
        ( updated , cmd )


