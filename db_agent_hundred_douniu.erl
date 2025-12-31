%%%--------------------------------------
%%% @Module  : db_agent_hundred_douniu
%%% @Author  : xws
%%% @Created : 2016.11.01
%%% @Description: 玩家牛牛数据处理
%%%--------------------------------------
-module(db_agent_hundred_douniu).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("hundred_douniu.hrl").

-define(TABLE_NAME, player_hundred_douniu).
-define(RECORD_NAME, player_hundred_douniu_ets).

-compile(export_all).

%% 获取玩家百人牛牛数据
get_player_hundred_douniu_data(PlayerId) ->
	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			init_data(PlayerId);
		ValueList ->
			PlayerShop = list_to_tuple([?RECORD_NAME|ValueList]),
			decode_data(PlayerShop)
	end.

%% 更新玩家百人牛牛数据
update_player_hundred_douniu_data(PlayerHundredDouniu) ->
	PlayerHundredDouniu1 = encode_data(PlayerHundredDouniu),
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerHundredDouniu1)),
    ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

init_data(PlayerId) ->
	NowDay = util:now_days(),
	Data = #?RECORD_NAME{player_id=PlayerId, next_refresh_day=NowDay + 1},
	Data1 = encode_data(Data),
	ValueList = erlang:tl(erlang:tuple_to_list(Data1)),
	?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList),
	Data.

encode_data(Data) ->
	Data.

decode_data(Data) ->
	Data.