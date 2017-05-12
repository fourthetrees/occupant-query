module Types exposing (..)
import Http
import Dict exposing (Dict)


type alias Model =
  { program : State
  , session : Session
  , archive : List Response
  }


type State = Init | Kiosk Survey | Form Survey | Fin


type Input = Select Selection | Submit Response


type Msg = Set State | User Input | Update ( Result Http.Error Survey )

-- type alias to help clarify when an integer is
-- intended to be used as a unique identified.
type alias Uid  = Int

-- type alias to clarify when a string is intended
-- for display to the user.
type alias Txt = String

type alias Option =
  { text : Txt
  , code : Uid
  }

type alias Question =
  { text : Txt
  , code : Uid
  , opts : List Option
  }

type alias Survey =
  { text : Txt
  , code : Uid
  , itms : List Question
  }

type alias Selection =
  { itm: Uid
  , opt: Uid
  }

type alias Session = Dict Uid Selection

type alias Response =
  { time: Int
  , code: Uid
  , sels: List Selection
  }
