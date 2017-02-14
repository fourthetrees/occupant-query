# Database

Design specification for the database backend that will eventually
be used for the occupant-query server.

## Table Prototypes

### `routing`

|  url   | deployment_id |
| -----  | ------------- |
| STRING | INTEGER       |
| ...    | ...           |

### `deployment_info`

| deployment_id |   kiosk   |  name  | description |
| ------------- | --------- | ------ | ----------- |
| INTEGER       | BOOL      | STRING | STRING      |
| ...           | ...       | ...    | ...         |


### `deployment_mapping`

| deployment_id |  query_id  |
| ------------- | ---------- |
| INTEGER       | INTEGER    |
| ...           | ...        |

### `questions`

| query_id   |  name   | question_text |
| ---------- | ------- | ------------- |
| INTEGER    | STRING  | STRING        |
| ...        | ...     | ...           |


### `options`

|  query_id  |  option_id  |  option_text  |
| ---------- | ----------- | ------------- |
| INTEGER    | INTEGER     | STRING        |
| ...        | ...         | ...           |


### `responses`

|  deployment_id  | query_id  | option_id  | timestamp  |
| --------------- | --------- | ---------- | ---------- |
| INTEGER         | INTEGER   | INTEGER    | DATETIME   |
| ...             | ...       | ...        | ...        |
