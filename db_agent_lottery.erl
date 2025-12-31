%% @author mxb
%% @doc @todo Add description to db_agent_lottery.


-module(db_agent_lottery).

-include("common.hrl").
-include("record.hrl").
-include("lottery.hrl").
%% ====================================================================
%% API functions
%% ====================================================================
-export([]).
-compile(export_all).

-define(SQL_LOTTERY_RANK_LIMIT, "select * from lottery_player order by ~s desc limit ~p;").
%% ====================================================================
%% Internal functions
%% ====================================================================

%% 获取所有玩家数据
get_all_lot_player_data() ->
	case ?DB_MODULE:select_all(?LOTTERY_PLAYER, "*" , []) of
        [] ->
            [];
        CountList ->
            lists:map(fun(CountData) -> 
                              CountInfo = list_to_tuple([?LOTTERY_PLAYER|CountData]),
                              CountInfo
                      end,
                      CountList)
    end.

%% 新增玩家数据
insert_lottery_player_data(CountInfo) ->
    ValueList = lists:nthtail(1, tuple_to_list(CountInfo)),
    FieldList = record_info(fields, ?LOTTERY_PLAYER),
    ?DB_MODULE:insert(?LOTTERY_PLAYER, FieldList, ValueList).

%%更新玩家数据
update_lottery_player_data(CountInfo) ->
	?DB_MODULE:update(lottery_player, [
									   {nick, CountInfo#lottery_player.nick},
									   {facelook, CountInfo#lottery_player.facelook},
									   {day_win_num, CountInfo#lottery_player.day_win_num}, 
									   {day_win_value, CountInfo#lottery_player.day_win_value},
									   {week_win_num, CountInfo#lottery_player.week_win_num},
									   {week_win_value, CountInfo#lottery_player.week_win_value},
									   {month_win_num, CountInfo#lottery_player.month_win_num},
									   {month_win_value, CountInfo#lottery_player.month_win_value}], 
					  [{uid, CountInfo#lottery_player.uid}]).

%% 获取天降祥瑞奖池数据
get_lottery_omen_reward_data(ID) ->
	case ?DB_MODULE:select_all(?LOTTERY_PUMP_REWARD, "*", [{id, ID}], [], []) of
		[] ->
			[];
		List ->
			F = fun(Data) ->
						Info = list_to_tuple([?LOTTERY_PUMP_REWARD | Data]),
						Info#lottery_pump_reward{pump_list = util:bitstring_to_term(Info#lottery_pump_reward.pump_list),
												 reward_list = util:bitstring_to_term(Info#lottery_pump_reward.reward_list)}
				end,
						
			[F(Data) || Data <- List]
	end.

%% 增加天降祥瑞奖池数据
insert_lottery_omen_reward_data(OmenInfo) ->
	case get_lottery_omen_reward_data(OmenInfo#lottery_pump_reward.id) of
		[] ->
			NewOmenInfo = OmenInfo#lottery_pump_reward{pump_list = util:term_to_bitstring(OmenInfo#lottery_pump_reward.pump_list),
													   reward_list = util:term_to_bitstring(OmenInfo#lottery_pump_reward.reward_list)},
			ValueList = lists:nthtail(1, tuple_to_list(NewOmenInfo)),
			FieldList = record_info(fields, ?LOTTERY_PUMP_REWARD),
			?DB_MODULE:insert(?LOTTERY_PUMP_REWARD, FieldList, ValueList);
		_ ->
			update_lottery_omen_reward_data(OmenInfo)
	end.

%% 更新天降祥瑞奖池数据
update_lottery_omen_reward_data(OmenInfo) ->
	?DB_MODULE:update(?LOTTERY_PUMP_REWARD, [
									   {pump_list, util:term_to_bitstring(OmenInfo#lottery_pump_reward.pump_list)},
									   {reward_list, util:term_to_bitstring(OmenInfo#lottery_pump_reward.reward_list)}], 
					  [{id, OmenInfo#lottery_pump_reward.id}]).

%% ======================排行榜==========================================

%% 根据类型排序，选择前10
get_top_ten_lottery_player(Type, Size) ->
	case Type of
		day_lottery ->
			Sql = io_lib:format(?SQL_LOTTERY_RANK_LIMIT, [day_win_value, Size]);
		week_lottery ->
			Sql = io_lib:format(?SQL_LOTTERY_RANK_LIMIT, [week_win_value, Size]);
		_ ->
			Sql = io_lib:format(?SQL_LOTTERY_RANK_LIMIT, [month_win_value, Size])
	end,
	
	case ?DB_MODULE:select_all(?LOTTERY_PLAYER, Sql) of
		[] ->
			[];
		DataList ->
			lists:map(fun(CountData) -> 
							  list_to_tuple([?LOTTERY_PLAYER|CountData])
					  end,
					  DataList)
	end.
	
%% 获取排行榜的数据
get_lottery_rank_info() ->
	case ?DB_MODULE:select_all(?LOTTERY_RANK, "*", []) of
		[] ->
			[];
		RankList ->
			lists:map(fun(Data) -> 
							  RankInfo = list_to_tuple([?LOTTERY_RANK|Data]),
							  RankInfo#lottery_rank{rank_info = util:bitstring_to_term(RankInfo#lottery_rank.rank_info),
													star_info = util:bitstring_to_term(RankInfo#lottery_rank.star_info),
													type = util:bitstring_to_term(RankInfo#lottery_rank.type),
													other = util:bitstring_to_term(RankInfo#lottery_rank.other)}
					  end,
					  RankList)
	end.


%% 更新排行榜
update_lottery_rank_info(RankInfo) ->
	%%io:format("~n=db=update_lottery_rank_info===RankInfo:~p==~n", [RankInfo]),
	?DB_MODULE:update(lottery_rank, [{star_info, util:term_to_bitstring(RankInfo#lottery_rank.star_info)},
									 {rank_info, util:term_to_bitstring(RankInfo#lottery_rank.rank_info)},
									 {update_time, RankInfo#lottery_rank.update_time},
									 {other, util:term_to_bitstring(RankInfo#lottery_rank.other)}], 
                      [{type, RankInfo#lottery_rank.type}]).
%% 插入排行榜数据
insert_lottery_rank_data(RankInfo) ->
	%%io:format("~n==insert_lottery_rank_data===RankInfo:~p==~n", [RankInfo#lottery_rank.rank_info]),
	?DB_MODULE:insert(?LOTTERY_RANK, [{type, RankInfo#lottery_rank.type}, 
									  {star_info, util:term_to_bitstring(RankInfo#lottery_rank.star_info)},
									  {rank_info, util:term_to_bitstring(RankInfo#lottery_rank.rank_info)},
									  {update_time, RankInfo#lottery_rank.update_time},
									  {other, util:term_to_bitstring(RankInfo#lottery_rank.other)}]).


%% ==============================================================================

%% 获取聚宝阁调控数据
get_lottery_control() ->
	case ?DB_MODULE:select_all(lottery_control, "*" , []) of
        [] ->
            [];
        CountList ->
            lists:map(fun(CountData) -> 
                              CountInfo = list_to_tuple([lottery_control|CountData]),
                              CountInfo
                      end,
                      CountList)
    end.

%% 更新聚宝阁调控数据
update_lottery_control(LotControl) ->
	%%io:format("~n=db=update_lottery_control===LotControl:~p==~n", [LotControl]),
	?DB_MODULE:update(lottery_control, [{quality, LotControl#lottery_control.quality},
										{all_control_num, LotControl#lottery_control.all_control_num},
										{lose_rate, LotControl#lottery_control.lose_rate},
										{left_control_num, LotControl#lottery_control.left_control_num},
										{profit_percent, LotControl#lottery_control.profit_percent}], 
					  [{uid, LotControl#lottery_control.uid}]).

%% 插入聚宝阁调控数据
insert_lottery_control(LotControl) ->
	%%io:format("~n==insert_lottery_control===LotControl:~p==~n", [LotControl]),
	ValueList = lists:nthtail(1, tuple_to_list(LotControl)),
    FieldList = record_info(fields, lottery_control),
    ?DB_MODULE:insert(lottery_control, FieldList, ValueList).


