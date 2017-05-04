module Comms exposing (..)
import Json.Decode as Jd
import Types exposing (..)
import Debug
import Http


handle_update : Model -> Result Http.Error Survey -> ( Model , Cmd Msg )
handle_update model result =
  case result of
    Ok(survey) ->
      ( { model | program = Kiosk survey }
      , Cmd.none )

    Err(error) ->
      let _ = Debug.log "error: " error
      in ( model, Cmd.none )


load_survey : Cmd Msg
load_survey =
  let
    request = Http.post "" Http.emptyBody jd_survey
    update = (\ r -> Update ( Debug.log "update: " r ) )
  in
    Http.send update request


jd_survey : Jd.Decoder Survey
jd_survey =
  let
    text = Jd.field "text"   Jd.string
    code = Jd.field "code"   Jd.int
    itms = Jd.field "itms" ( Jd.list jd_question )
  in
    Jd.map3 Survey text code itms


jd_question : Jd.Decoder Question
jd_question =
  let
    text = Jd.field "text" Jd.string
    code = Jd.field "code" Jd.int
    opts = Jd.field "opts" ( Jd.list jd_option )
  in
    Jd.map3 Question text code opts


jd_option : Jd.Decoder Option
jd_option =
  let
    text = Jd.field "text" Jd.string
    code = Jd.field "code" Jd.int
  in
    Jd.map2 Option text code
