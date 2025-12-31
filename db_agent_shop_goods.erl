%%%--------------------------------------
%%% @Module  : db_agent_shop_goods
%%% @Author  : xws
%%% @Created : 2016.08.16
%%% @Description: 玩家数据处理模块
%%%--------------------------------------
-module(db_agent_shop_goods).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").

-compile(export_all).

%% 获取所有商城物品数据
get_all_shop_goods() ->
	case ?DB_MODULE:select_all(shop_goods, "*", []) of
		DataList when is_list(DataList) andalso length(DataList) >  0 ->
			[list_to_tuple([shop_goods|DataItem]) || DataItem <- DataList];
		_ ->
			[]
	end.

%% 创建新商品数据
add_new_shop_goods(GoodsId, GoodsType, Num) ->
	FieldList = [goods_id, goods_type, goods_num],
	ValueList = [GoodsId, GoodsType, Num],
	?DB_MODULE:insert_get_id(shop_goods, FieldList, ValueList).

%% 更新商城物品数据
update_shop_goods(GoodsId, Num) ->
    ?DB_MODULE:update(shop_goods, [{goods_num, Num}], [{goods_id, GoodsId}]).

%% 获取最近兑换记录
get_order_history() ->
	case ?DB_MODULE:select_row(shop_exchange_history, "histroy_list", [{id, 1}], [], [1]) of
		[] ->
			Data = {0, []},
			update_order_history(Data),
			Data;
		[Data] ->
			util:bitstring_to_term(Data)
	end.

%% 更新最近兑换记录
update_order_history(Data) ->
	String = util:term_to_string(Data),
	?DB_MODULE:replace(shop_exchange_history, [{id, 1}, {histroy_list, String}]).