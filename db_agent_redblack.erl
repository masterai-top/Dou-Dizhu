%%%--------------------------------------
%%% @Module  : db_agent_redblack
%%% @Author  : xws
%%% @Created : 2017.2.27
%%% @Description: 玩家红黑数据处理
%%%--------------------------------------
-module(db_agent_redblack).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("redblack.hrl").

-define(TABLE_NAME,  player_redblack).
-define(RECORD_NAME, player_redblack_ets).

-compile(export_all).

%% 获取玩家红黑大战数据
get_player_redblack_data(PlayerId) ->
	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			init_data(PlayerId);
		ValueList ->
			PlayerShop = list_to_tuple([?RECORD_NAME|ValueList]),
			decode_data(PlayerShop)
	end.

%% 更新玩家红黑大战数据
update_player_redblack_data(PlayerRedblack) ->
	PlayerRedblack1 = encode_data(PlayerRedblack),
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerRedblack1)),
    ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

init_data(PlayerId) ->
	NowDay = util:now_days(),
	Data = #?RECORD_NAME{player_id=PlayerId},
	Data1 = encode_data(Data),
	ValueList = erlang:tl(erlang:tuple_to_list(Data1)),
	?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList),
	Data.

encode_data(Data) ->
	String1 = util:term_to_string(Data#player_redblack_ets.last_20_yazhu_coin_list),
	String2 = util:term_to_string(Data#player_redblack_ets.last_20_ret_list),
	String3 = util:term_to_string(Data#player_redblack_ets.picked_rank_list),
	Data#player_redblack_ets{last_20_yazhu_coin_list=String1, last_20_ret_list=String2, picked_rank_list=String3}.

decode_data(Data) ->
	Term1 = util:bitstring_to_term(Data#player_redblack_ets.last_20_yazhu_coin_list),
	Term2 = util:bitstring_to_term(Data#player_redblack_ets.last_20_ret_list),
	Term3 = util:bitstring_to_term(Data#player_redblack_ets.picked_rank_list),
	Data#player_redblack_ets{last_20_yazhu_coin_list=Term1, last_20_ret_list=Term2, picked_rank_list=Term3}.





%% 更新玩家今日赢钱
update_player_day_win(PlayerId, TotalCoin) ->
    ?DB_MODULE:replace(player_redblack_day_win, [player_id, total_coin], [PlayerId, TotalCoin]).

%% 更新玩家今日\压钱
update_player_day_stake(PlayerId, TotalCoin) ->
    ?DB_MODULE:replace(player_redblack_day_stake, [player_id, total_coin], [PlayerId, TotalCoin]).

%% 更新玩家今周赢钱
update_player_week_win(PlayerId, TotalCoin) ->
    ?DB_MODULE:replace(player_redblack_week_win, [player_id, total_coin], [PlayerId, TotalCoin]).

%% 更新玩家总共赢钱
update_player_all_win(PlayerId, TotalCoin) ->
    ?DB_MODULE:replace(player_redblack_all_win, [player_id, total_coin], [PlayerId, TotalCoin]).



%% 加载红黑数据
load_redblack_data() ->
	case ?DB_MODULE:select_row(redblack, "*", [{id, 1}], [], [1]) of
		[] ->
			[];
		ValueList ->
			Redblack = list_to_tuple([ets_redblack|ValueList]),
			decode_redblack(Redblack)
	end.

%% 更新红黑数据
update_redblack_data(Redblack) ->
	EnRedblack = encode_redblack(Redblack),
	ValueList = erlang:tl(erlang:tuple_to_list(EnRedblack)),
	?DB_MODULE:replace(redblack, record_info(fields, ets_redblack), ValueList).



encode_redblack(Data) ->
	String1 = util:term_to_string(Data#ets_redblack.last_day_win_rank_list),
	String2 = util:term_to_string(Data#ets_redblack.last_week_win_rank_list),
	String3 = util:term_to_string(Data#ets_redblack.last_day_rich_rank_list),
	String4 = util:term_to_string(Data#ets_redblack.supreme_win_rank_list),
	Data#ets_redblack{
		last_day_win_rank_list = String1,
		last_week_win_rank_list = String2,
		last_day_rich_rank_list = String3,
		supreme_win_rank_list = String4
	}.
 
decode_redblack(Data) ->
	Term1 = util:bitstring_to_term(Data#ets_redblack.last_day_win_rank_list),
	Term2 = util:bitstring_to_term(Data#ets_redblack.last_week_win_rank_list),
	Term3 = util:bitstring_to_term(Data#ets_redblack.last_day_rich_rank_list),
	Term4 = util:bitstring_to_term(Data#ets_redblack.supreme_win_rank_list),
	Data#ets_redblack{
		last_day_win_rank_list = Term1,
		last_week_win_rank_list = Term2,
		last_day_rich_rank_list = Term3,
		supreme_win_rank_list = Term4
	}.