module Types exposing (..)
-- DEPENDENCIES --
import Time
import Http
import Dict

-- TYPES --

-- STATE TYPES --
-- Current page; either query page or splash page.
type Page = QueryPage | SplashPage | StaticPage String

type Paradigm = Form | Kiosk

-- Various aliases for code clarity.
type alias Vote      = String
type alias Splash    = String
type alias Server    = String
type alias Question  = String
type alias QueryID   = String
type alias Timestamp = Time.Time
type alias JDict     = Dict.Dict String String


-- Represents a single selection event.
-- Form select indicates a multi-selection paradigm.
-- Kiosk select indicates a single-selection paradigm.
type alias Selection = ( QueryID, Vote )

-- Represents a set of selections
type alias Selections = Dict.Dict QueryID Vote

-- Represents a collection of votes.
type alias Entry =
  { selections : Selections
  , time       : Timestamp
  }

-- Represents a record of all submissions.
type alias Archive  = List Entry

-- Represents a question and a series of responses.
type alias Query =
  { question  : Question
  , responses : List Vote
  , queryID   : QueryID
  }

-- Represents a collection of all queries.
type alias Queries = List Query

-- Represents semi-perminant configuration options.
type alias Config =
  { splash_interval : Float
  , upload_interval : Float
  , server_address  : Server
  , splash_text     : Splash
  , kiosk_mode      : Bool
  }

-- Represents the arguments passed to the app at initialization.
type alias Deployment =
  { queries : Queries
  , config  : Config
  }

-- Represents the state of the application at a given instance.
type alias Model =
  { page       : Page
  , queries    : Queries
  , config     : Config
  , archive    : Archive
  , uploads    : Archive
  , selections : Selections
  , is_filled  : Bool
  , paradigm   : Paradigm
  }

-- /

-- UPDATE TYPES --

-- Alias for an attempted communication with the server.
type alias Comms = Result Http.Error ( Dict.Dict String String )

-- Core MSG type representing events to be handled by the update function.
type Msg =
  Select Selection |
  Save Entry       |
  Recieve Comms    |
  Submit           |
  Upload           |
  Resume

-- /
