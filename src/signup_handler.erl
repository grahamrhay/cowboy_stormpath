-module(signup_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-record(state, {}).

init(_, Req, _Opts) ->
    {ok, Req, #state{}}.

handle(Req, State=#state{}) ->
    {Method, _} = cowboy_req:method(Req),
    {ok, Reply} = handle_req(Method, Req),
    {ok, Reply, State}.

handle_req(<<"GET">>, Req) ->
    render_signup_page([], Req);

handle_req(<<"POST">>, Req) ->
    {ok, Body, Req2} = cowboy_req:body_qs(Req),
    Email = proplists:get_value(<<"email">>, Body),
    Password = proplists:get_value(<<"password">>, Body),
    GivenName = proplists:get_value(<<"givenName">>, Body),
    Surname = proplists:get_value(<<"surname">>, Body),
    Res = stormpath:create_user(#{
        email => Email,
        password => Password,
        givenName => GivenName,
        surname => Surname
    }),
    case Res of
        {ok, UserInfo, Req2} ->
            {ok, Req3} = cowboy_session:set(<<"user">>, UserInfo, Req2),
            cowboy_req:reply(302, [{<<"Location">>, <<"/user/info">>}], Req3);
        {error, Error} ->
            render_signup_page([{error, Error}, {email, Email}, {given_name, GivenName}, {surname, Surname}], Req2)
    end;

handle_req(_, Req) ->
    cowboy_req:reply(405, [], Req).

render_signup_page(Data, Req) ->
    {ok, Body2} = signup_dtl:render(Data),
    cowboy_req:reply(200, [{<<"content-type">>, <<"text/html">>}], Body2, Req).

terminate(_Reason, _Req, _State) ->
    ok.
