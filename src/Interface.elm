module Interface exposing (..)
import Html exposing (Html)
import Html.Attributes as Ha
import Html.Events as He
import Types exposing (..)


render_kiosk : Model -> Survey -> Html Msg
render_kiosk model survey =
  splash "~kiosk placeholder~"


render_form : Model -> Survey -> Html Msg
render_form model survey =
  splash "~form placeholder~"


splash : String -> Html Msg
splash text =
  Html.h2
    [ Ha.class "splash" ]
    [ Html.text text    ]


handle_input : Model -> Input -> ( Model, Cmd Msg )
handle_input model input =
  case input of
    Submit response ->
      ( model, Cmd.none ) -- placeholder
    Select selection ->



-- generate a question from a `Question` specification
-- and (if exists) the id of the currently selected option.
question : Question -> Maybe Id -> Html Msg
question spec selected =
  let
    text = question_text spec.text
    opts = options spec.code spec.opts selected
  in
    Html.div
      [ Ha.classList [ ( "question", True ) ] ]
      [ text, opts ]


-- generate question text.
question_text : Txt -> Html Msg
question_text text =
  Html.div
    [ Ha.classList [ ( "question-text", True ) ] ]
    [ Html.text text ]


-- accepts a question-id, list of options, and (if exists),
-- the id of the currently selected option.  Generates a div
-- containing a selector for each listed option.
options : Id -> List Option -> Maybe Id -> Html Msg
options parent opts selected =
  let
    is_selected = (\ oid ->
      case selected of
        Some uid ->
          uid == oid
        Nothing -> False )
    mkSelector = (\ opt ->
      selector
        { itm = parent , opt = opt.code }
        opt.text
        is_selected opd.code )
  in
    Html.div
      [ Ha.classList [ ( "options", True ) ] ]
      List.map mkSelector opts


-- generate a button which fires off a `Selection`
-- event when clicked, and can have it's membership
-- in the `"selected"` class toggled with a bool.
selector : Selection -> Txt -> Bool -> Html Msg
selector selection text selected =
  Html.button
    [ He.onClick User ( Select selection )
    , Ha.classList
      [ ( "selected" , selected )
      , ( "selector" , True   ) ]
    ]
    [ Html.text text ]
