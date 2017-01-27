# occupant-query

A simple elm app for displaying auto-generated queries on web kiosks.

## Features

- Elm's strong type system and compile-time checks, allow for quick, smooth,
and error-free deployment on even minimally powered devices.

- This app continues to function normally if/when the hosting device loses internet connectivity;
all data is temporarily moved to local storage until connectivity with the server is re-established.

- A simple [flask](http://flask.pocoo.org/) server is included in the `server/` directory,
which dynamically provides parameters to the elm app & recieves responses.

## Usage

To compile & launch:

````
~/occupant-query$ elm-make src/Main.elm --output=server/static/main.js
Success! Compiled 1 module.                                         
Successfully generated server/static/main.js
~/occupant-query$ cd server/
~/occupant-query/server$ export FLASK_APP=server.py
~/occupant-query/server$ flask run
 * Serving Flask app "server"
 * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
````

An example query is available at `http://127.0.0.1:5000/queries/test_query`.
The server auto-generates queries from JSON files in the `server/tmp/queries/` directory.
Check out [`server/tmp/queries/test_query.json`](./server/tmp/queries/test_query.json)
to see the config file which generates the above example.
