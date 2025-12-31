%%%--------------------------------------
%%% @Module  : db_agent_recharge
%%% @Author  :
%%% @Created :
%%% @Description: 
%%%--------------------------------------
-module(db_agent_recharge).

-include("common.hrl").
-include("record.hrl").
-include("recharge.hrl").

-define(TABLE_NAME, player_recharge).
-define(RECORD_NAME, player_recharge).


-compile(export_all).

%% 玩家商行数据自身操作 
%-----------------------------------
%% 加载玩家充值数据
get_player_recharge(PlayerId) ->
    case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
        [] ->
            init_data(PlayerId);
        ValueList ->
            Data = list_to_tuple([?RECORD_NAME|ValueList]),
            decode_player_recharge(Data)
    end.

%% 更新玩家充值数据
update_player_recharge(PlayerRecharge) ->
    PlayerRecharge1 = encode_player_recharge(PlayerRecharge),
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerRecharge1)),
    ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

init_data(PlayerId) ->
    Data = #player_recharge{player_id = PlayerId},
    Data1 = encode_player_recharge(Data),
    ValueList = erlang:tl(erlang:tuple_to_list(Data1)),
    ?DB_MODULE:insert(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList),
    Data.

encode_player_recharge(PlayerRecharge) ->
    String1 = util:term_to_string(PlayerRecharge#player_recharge.tehui_list),
    String2 = util:term_to_string(PlayerRecharge#player_recharge.recharged_list),
	String3 = util:term_to_string(PlayerRecharge#player_recharge.time_limit_recharge_list),
    PlayerRecharge#player_recharge{tehui_list=String1, recharged_list=String2,
								   time_limit_recharge_list = String3}.

decode_player_recharge(PlayerRecharge) ->
    Term1 = util:bitstring_to_term(PlayerRecharge#player_recharge.tehui_list),
    Term2 = util:bitstring_to_term(PlayerRecharge#player_recharge.recharged_list),
	Term3 = util:bitstring_to_term(PlayerRecharge#player_recharge.time_limit_recharge_list),
    PlayerRecharge#player_recharge{tehui_list=Term1, recharged_list=Term2,
								   time_limit_recharge_list = Term3}.

