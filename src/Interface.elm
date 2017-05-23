module Interface exposing (..)

import Html exposing (Html)
import Html.Attributes as Ha
import Types exposing (..)
import Dict exposing (Dict)
import Components as Cmp
import Utilities as Utils


-- generate a kiosk-style interface.
render_kiosk : Pgrm -> Html Msg
render_kiosk pgrm =
  Cmp.splash "~kiosk placeholder~"


-- generate a form-style interface.
render_form : Pgrm -> Html Msg
render_form { spec , sess } =
  let
    questions = form_questions sess spec.itms
    sub = Cmp.submit ( Utils.is_filled spec sess )
  in
    Html.div
      [ Ha.class "form" ]
      [ questions , sub ]


-- generate the questions for a form-style interface.
form_questions : Session -> List Question -> Html Msg
form_questions session questions =
  let
    generate = (\ spec ->
      Cmp.question spec
        ( case Dict.get spec.code session of
          Just selection -> Just selection.opt
          Nothing -> Nothing )
      )
  in
    Html.div
      [ Ha.class "form-questions"   ]
      ( List.map generate questions )


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



