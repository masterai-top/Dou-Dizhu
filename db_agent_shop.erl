%%%--------------------------------------
%%% @Module  : db_agent_shop_goods
%%% @Author  : xws
%%% @Created : 2016.09.05
%%% @Description: 玩家数据处理模块
%%%--------------------------------------
-module(db_agent_shop).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("shop.hrl").

-define(TABLE_NAME, player_shop).

-compile(export_all).

%% 获取玩家商城数据
get_player_shop_data(PlayerId) ->
	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			init_data(PlayerId);
		ValueList ->
			PlayerShop = list_to_tuple([?TABLE_NAME|ValueList]),
			decode_data(PlayerShop)
	end.

%% 获取所有玩家商店数据
get_all_player_shop_data() ->
	case ?DB_MODULE:select_all(?TABLE_NAME, "*", []) of
		DataList when is_list(DataList) andalso length(DataList) >  0 ->
			Fun = fun(DataItem) ->
						  decode_data(list_to_tuple([?TABLE_NAME|DataItem]))
				  end ,
			lists:map(Fun,DataList);
		_ ->
			[]
	end.

%% 更新玩家商品购买记录
update_player_shop_buyhis(PlayerId, BuyHis) ->
	StrBuyHis = util:term_to_string(BuyHis),
	?DB_MODULE:update(?TABLE_NAME, [{buy_history_list, StrBuyHis}], [{player_id, PlayerId}]).



%% 获取玩家收货信息
get_player_receive_info(PlayerId) ->
	case ?DB_MODULE:select_row(player_receive_info, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			#player_receive_info{player_id=PlayerId};
		ValueList ->
			list_to_tuple([player_receive_info|ValueList])
	end.

%% 更新玩家收货信息
update_player_receive_info(PlayerReceiveInfo) ->
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerReceiveInfo)),
    ?DB_MODULE:replace(player_receive_info, record_info(fields, player_receive_info), ValueList).

init_data(PlayerId) ->
	Data = #player_shop{player_id = PlayerId},
	%%Data1 = encode_data(Data),
	%%ValueList = erlang:tl(erlang:tuple_to_list(Data1)),
	%%?DB_MODULE:insert(?TABLE_NAME, record_info(fields, player_shop), ValueList),
	Data.

encode_data(Data) ->
	String = util:term_to_string(Data#player_shop.buy_history_list),
	Data#player_shop{buy_history_list = String}.

decode_data(Data) ->
	Term = util:bitstring_to_term(Data#player_shop.buy_history_list),
	Data#player_shop{buy_history_list = Term}.