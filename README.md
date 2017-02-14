# occupant-query

A simple elm app for displaying auto-generated queries on web kiosks and recording responses.

## Features

- Elm's strong type system and compile-time checks, allow for quick, smooth,
and error-free deployment on even minimally powered devices.

- This app continues to function normally if/when the hosting device loses internet connectivity;
all data is held in-app until connectivity with the server is re-established.

- Questions can be presented individually, or as forms.  Rotating lists of questions
can be stored in-app, allowing continued rotation during the offline operation.

- A simple [flask](http://flask.pocoo.org/) server is included in the [`server/`](./server/) directory,
which dynamically provides parameters to the elm app & logs responses.  This server's functionality
is easy to integrate into existing flask codebases, and allows for drop-in insertion of custom code for
retrieving configuration options and storing response values.

## Usage

### Compile & Launch:

````
$ elm-make src/Main.elm --output=server/static/main.js
$ cd server/
$ export FLASK_APP=server.py
$ flask run
````
You should see something like this:

````
 * Serving Flask app "server"
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
````

Examples can be found at ['127.0.0.1:5000/deployments/example_form'](http://127.0.0.1:5000/deployments/example_form),
and [`127.0.0.1:5000/deployments/example_rotating`](http://127.0.0.1:5000/deployments/example_rotating).
These examples are generated from `json` encoded files located in [`server/tmp/queries/`](./server/tmp/queries).

### Adding Your Own Content:

The quickest way to start adding your own content is to add new `json` files
to [`server/tmp/queries/`](./server/tmp/queries).  To this end, take a moment
to familiarize yourself with the terms and structures used for content encoding:

A *query* is a unit consisting of a question, a list of responses,
and a question id.  Queries are encoded as `json` objects like so:
````json
{
  "question"  : "...",
  "responses" : [ "..." ],
  "queryID"   : "..."
}
````
The `question` field is just a string containing the text of the question
that is to be displayed.  The `responses` field is a list of strings which
will be rendered as the possible responses to the question.  The `queryID`
field is a string which can be any unique identifier.  When responses
are recorded, they are paired with their query id in order to indicate
which query they correspond to.

A *configuration* is a set of parameters which tell the elm app how to behave,
as well as special messages to display to the user (e.g.; the `splash_text` field
indicates what text to display when a user submits a response).  All configuration
options have default values, and as such are optional.  The default values
live in [`server/tmp/config/deployment_defaults.json`](./server/tmp/config/deployment_defaults.json).
We override the default value of a configuration option with a `config`
field.  Here is an example of how to change the `server_address` option
s.t. responses are logged back to the server under the handle `foo`:
````json
"config" : {
  "server_address"  : "../callback/foo"
}
````

The *deployment* is the final data structure that gets passed to the elm app by
the server.  It consists of a list of queries and a fully populated `config`.
Since flask will automatically populate any unfilled `config` fields from
the defaults file, a deployment *file* is only required to implement a `queries`
field:
````javascript
{
  "queries" : [ /*list of queries */ ],
  "config"  : { /*this is optional*/ }
}
````
Technically, a `queries` field *can* be an empty list.  While this may seem
rather counter-productive to allow, one of the design goals of this application
is to support the assignment of unique deployment URLs for each web kiosk
that displays it.  Because of this, it is necessary that the application gracefully
handle the situation where there are no queries which currently need displaying.

## Development

### Current:

Work is currently focusing around establishing an optional database
backend for the server.  A separate project is currently underway to
produce an ergonomic graphical interface by which experimenters may be
able to add their own deployments and questions to a database,
thereby removing any technical barriers to usage of this tool.
Further information on the proposed database model can be found
in [`doc/database.md`](./doc/database.md).  The long-term plan
is to allow for spinning up of a 'light' version of the server, hosting no
graphical administration interface and configured only through
JSON encoded files, and a a 'full' version of the server which implements
the full database and GUI.  This will allow individuals to easily
spin up a small occupant-query server on a raspberry-pi or other similarly
inexpensive IOT device if desired.

### Upcoming:

An update functionality allowing the app to
request and updated deployment on some regular interval.
This may possibly include the addition of some kind of scheduling feature,
whereby the app may be able to pre-load a new deployment, and switch over
at some pre-determined time.


### Potential:

Move away from css stylesheets to a dynamically generated css
implementation.  All things being equal, it is preferable to keep appearance
separate from logic.  That being said, there is a very real benefit to being
able to exercise control of appearance directly from the deployment object.

### Contribution:

Pull-requests welcome!
