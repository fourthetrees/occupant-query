module Interface exposing (..)

import Html exposing (Html)
import Types exposing (..)
import Dict exposing (Dict)
import Components exposing (..)




handle_input : Model -> Input -> ( Model , Cmd Msg )
handle_input model input =
  case input of
    Submit response ->
      ( model, Cmd.none ) -- placeholder
    Select selection ->
      handle_selection model selection





render_kiosk : Config -> Program -> Html Msg
render_kiosk conf pgrm =
  splash "~kiosk placeholder~"


render_form : Config -> Program -> Html Msg
render_form conf pgrm =
  splash "~form placeholder~"


-- update `pgrm`  when a selection event occurs.
add_selection : Selection -> Program -> Program
add_selection selection program =
  let
    sess = Dict.insert selection.itm selection program.sess
  in
    { program | sess = sess }


-- check if all options have been selected in a given session.
is_filled : Survey -> Session -> Bool
is_filled survey session =
  let
    fltr = (\item bool ->
      if bool then
        Dict.member item.code session
      else False )
  in
    List.foldr fltr True survey.itms
