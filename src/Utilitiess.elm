module Utilities exposing (..)
import Time exposing (Time)
import Dict exposing (Dict)



to_response : Uid -> Session -> Time -> Response
to_response uid session time =
  let
    seconds = Int ( Time.inSeconds time )
    selections = Dict.values session
  in
    { time = seconds
    , code = uid
    , sels = selections
    }
