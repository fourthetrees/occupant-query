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




render_kiosk : Model -> Survey -> Html Msg
render_kiosk model survey =
  splash "~kiosk placeholder~"


render_form : Model -> Survey -> Html Msg
render_form model survey =
  splash "~form placeholder~"


-- update the model when a selection event occurs.
handle_selection : Model -> Selection -> ( Model , Cmd Msg )
handle_selection model selection =
  let
    new_sess = Dict.insert selection.itm selection model.session
  in
    ( { model | session = new_sess }
    , Cmd.none )


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
