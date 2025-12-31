
-module(db_agent_huopin).

-include("common.hrl").
-include("record.hrl").
-include("huopin_niu.hrl").

-define(TABLE_NAME, player_huopin_niu).
-define(RECORD_NAME, ets_player_huopin_niu).

%% API
-compile(export_all).

%% 获取玩家火拼牛牛数据
get_player_huopin_data(PlayerId) ->
	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{uid, PlayerId}], [], [1]) of
		[] ->
			init_data(PlayerId);
		ValueList ->
			PlayerShop = list_to_tuple([?RECORD_NAME|ValueList]),
			decode_data(PlayerShop)
	end.

%% 更新玩家火拼牛牛数据
update_player_huopin_data(PlayerData) ->
	PlayerData1 = encode_data(PlayerData),
	ValueList = erlang:tl(erlang:tuple_to_list(PlayerData1)),
	?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

init_data(PlayerId) ->
	Data = #?RECORD_NAME{uid=PlayerId},
	Data1 = encode_data(Data),
	ValueList = erlang:tl(erlang:tuple_to_list(Data1)),
	?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList),
	Data.

encode_data(Data) ->
	Data.

decode_data(Data) ->
	Data.
