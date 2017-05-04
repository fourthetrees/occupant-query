module Types exposing (..)
import Http


type alias Model =
  { program : State
  , session : Maybe ( List Selection )
  , archive : Maybe ( List Response  )
  }


type State = Init | Kiosk Survey | Form Survey | Fin


type Input = Select Selection | Submit Response


type Msg = Set State | User Input | Update ( Result Http.Error Survey )


type alias Option =
  { text : String
  , code : Int
  }

type alias Question =
  { text : String
  , code : Int
  , opts : List Option
  }

type alias Survey =
  { text : String
  , code : Int
  , itms : List Question
  }

type alias Selection =
  { itm: Int
  , opt: Int
  }

type alias Response =
  { time: Int
  , code: Int
  , sels: List Selection
  }
