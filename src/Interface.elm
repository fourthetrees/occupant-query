module Interface exposing (..)
import Html exposing (Html)
import Html.Attributes as Ha
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
  ( model, Cmd.none ) -- placeholder
