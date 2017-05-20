module Utilities exposing (..)

import Types exposing (..)
import Time exposing (Time)
import Dict exposing (Dict)
import Task exposing (Task)


-- accepts a closure which converts `Time` to some
-- `msg`, generating a command to get current time. 
timestamp : ( Time -> msg ) -> Cmd msg
timestamp closure =
  Task.perform closure Time.now


-- attempt to 
submit_session : Pgrm -> Result () ( Pgrm , Cmd Msg )
submit_session pgrm =
  if is_filled pgrm.spec pgrm.sess then
    let
      save = (\ time ->
        Save
          { time = floor ( Time.inSeconds time )
          , code = pgrm.spec.code
          , sels = Dict.values pgrm.sess
          } )
    in
      Ok
        ( { pgrm | sess = Dict.empty }
        , timestamp save )

  else Err ()



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


insert_selection : Selection -> Pgrm -> Pgrm
insert_selection selection pgrm =
  let
    sess = Dict.insert selection.itm selection pgrm.sess
  in
    { pgrm | sess = sess }


add_response : Pgrm -> Response -> Pgrm
add_response pgrm response =
  let
    arch = pgrm.arch ++ [ response ]
  in
    { pgrm | arch = arch }

