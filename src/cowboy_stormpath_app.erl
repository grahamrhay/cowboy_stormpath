-module(cowboy_stormpath_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    cowboy_stormpath_sup:start_link().

stop(_State) ->
    ok.
