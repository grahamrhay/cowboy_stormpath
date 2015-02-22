-module(stormpath_tests).

-include_lib("eunit/include/eunit.hrl").

login_test() ->
    start_apps(),
    {ok, Body} = stormpath:login(<<"tk421@stormpath.com">>, <<"Changeme1">>),
    ?debugFmt("Body: ~p~n", [Body]).

create_user_test() ->
    start_apps(),
    UserInfo = #{
      email => <<"elvis3@gmail.com">>,
      password => <<"Password1">>,
      givenName => <<"Elvis">>,
      surname => <<"Presley">>
    },
    {ok, Body} = stormpath:create_user(UserInfo),
    ?debugFmt("Body: ~p~n", [Body]).

start_apps() ->
    {ok,_} = application:ensure_all_started(hackney).
