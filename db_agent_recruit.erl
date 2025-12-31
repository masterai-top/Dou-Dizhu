%%%--------------------------------------
%%% @Module  : db_agent_recruit
%%% @Author  : xws
%%% @Created : 2016.11.02
%%% @Description: 玩家招募数据
%%%--------------------------------------
-module(db_agent_recruit).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("recruit.hrl").

-define(TABLE_NAME, player_recruit).
-define(RECORD_NAME, player_recruit).

-compile(export_all).

%% 获取玩家招募数据
get_player_recruit_data(PlayerId) ->
	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			init_data(PlayerId);
		ValueList ->
			PlayerShop = list_to_tuple([?RECORD_NAME|ValueList]),
			decode_data(PlayerShop)
	end.

%% 更新玩家招募
update_player_recruit_data(PlayerRecruit) ->
	PlayerRecruit1 = encode_data(PlayerRecruit),
    ?PRINT("PlayerRecruit: ~p", [PlayerRecruit1]),
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerRecruit1)),
    ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

init_data(PlayerId) ->
	Data = #?RECORD_NAME{player_id=PlayerId},
	Data1 = encode_data(Data),
	ValueList = erlang:tl(erlang:tuple_to_list(Data1)),
	?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList),
	Data.

encode_data(Data) ->
	Data.

decode_data(Data) ->
	Data.