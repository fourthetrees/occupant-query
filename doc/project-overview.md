# occupant-query project overview

## Motivation

The primary motivation for this project it two-fold.
Firstly, developing a simple open-source method of
delivering surveys and questionnaires to building
occupants offers researchers much more control than is
available via proprietary survey software/services. Secondly,
existing survey methods are dependent on constant
internet connectivity, which limits their applicability
for display on kiosks and other embedded building systems.

## High Level Overview

This project can be roughly divided into two parts; server
and web-application.  The server code is hosted by the researcher
in order to distribute surveys and accumulate responses.  The
web-application is loaded onto building kiosks, or can be accessed
directly by the browsers of building occupants.

### Server

The server code is written in `python`, and is the interface between
a database of questionnaires, and the outside world.  Researchers
add questionnaires to the database, and assign urls to those
questionnaires.  The urls to the questionnaires can then either
be loaded onto building kiosks, or given to building occupants
directly.  When a given url is accesses, the server will upload
the web-application to the client's browser, and seed the application
with the survey to be displayed.  When the web-application has accumulated
the occupant's responses, it uploads these responses back to the server
for storage and analysis.

### Web-Application

The web-application code is written in `elm`, and is the means
by which building occupants are displayed questionnaires, and by
which responses are input.  All responses are recorded with
second-accurate timestamps, allowing researchers to confidently
correlate responses with real-world events such as fluxuations in
temperature or light-levels.  When being displayed in a building
occupant's browser, questionnaires are displayed as a single
form, which is submitted in its entirety once responses have been
selected for all questions.  When being displayed on a kiosk,
questions are submitted individually.  Because it is desirable that
a building kiosk continue to function normally during intermittent
internet connectivity, the web-application is capable of storing and
time-stamping responses locally while the connection to the server is
unavailable.  This further empowers to researcher to make correlations
between response patterns and environmental building factors.

## Technology

This project is designed to leverage modern web technologies to
provide the best data possible for researchers to use during building
studies.  The goal of the technology choices made here are threefold;
to ensure quality of data, to allow for ease of re-use and modification
of the project-code, and to provide as seamless and friendly of an experience
to building occupants as possible.  

### Python

The server component of this project is written in the
[Python Programming Language](https://www.python.org/).
Python is an open-source language which has become the de facto standard
in modern scientific computing.  It is characterized by being easy
to use, versatile, and well supported by the academic & open-source
communities.  By writing our server-side code in Python, we are able
to ensure that it will be readable and modifiable by as large of a
sub-set of the academic community as possible.  Additionally, the choice
of using Python means that a large number of free and easy to use tools
are immediately available to us, such as the
[Flask Web Framework](http://flask.pocoo.org/), which we use to manage
all of the http `GET` and `POST` requests which our server must handle.

### Elm

The web-application component of this project is written in the
[Elm Programming Language](http://elm-lang.org/).  Elm is an open-source
language that is used for writing fast and reliable web-applications which
are capable of running in all modern browsers with no installation of
plugins/drivers/etc...  The Elm language compiles to ordinary HTML, CSS,
and JavaScript (the 'native' languages of the web browser), but gives us the
ability to collectively analyze and modify our codebase as a single cohesive
entity.  As a result, web-applications written in Elm are significantly
faster and more reliable than those which are written in HTML, CSS, and
JavaScript directly.  For our particular purposes, speed
and reliability translate into two important benefits: more users being
willing to participate in our research, and computational demand on our
building systems (computational efficiency equals power efficiency).
