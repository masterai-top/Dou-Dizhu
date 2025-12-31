%%%--------------------------------------
%%% @Module  : db_agent_goods
%%% @Author  :
%%% @Created :
%%% @Description: 物品处理模块
%%%--------------------------------------
-module(db_agent_goods).

-include("common.hrl").
-include("record.hrl").

-compile(export_all).



%% 获取商城模版数据
get_all_shop_goods() ->
	case ?DB_MODULE:select_all(temp_shop, "*", []) of
		DataList when is_list(DataList) andalso length(DataList) >  0 ->
			Fun = fun(DataItem) ->
						  list_to_tuple([temp_shop|DataItem])
				  end ,
			lists:map(Fun,DataList);
		_ ->
			[]
	end.

%%获取在线玩家背包物品表
%%玩家登陆成功后获取
get_player_goods_by_uid(PlayerId) ->	
    case ?DB_MODULE:select_all(goods, "*", [{uid, PlayerId}]) of
        DataList when is_list(DataList) andalso length(DataList) >  0 ->
            Fun = fun(DataItem) ->
                          Info = list_to_tuple([goods|DataItem]),
						  Info
						  %%Info#goods{other = util:bitstring_to_term(Info#goods.other)}
                  end ,
            lists:map(Fun,DataList);
        _ ->
            []
    end .

			
%%分页获取玩家背包物品数量
get_player_goods_by_uid(PlayerId,Offset,Limit) ->
    case  ?DB_MODULE:select_all(goods, "*", [{uid,PlayerId}],[],[Offset,Limit]) of
        DataList when is_list(DataList) andalso length(DataList) >  0 ->
            Fun = fun(DataItem) ->
                          Info = list_to_tuple([goods|DataItem]),
						  Info
						  %%Info#goods{other = util:bitstring_to_term(Info#goods.other)}                       
                  end ,
            lists:map(Fun,DataList);
        _ ->
            []
    end.

%%获取玩家物品列表
get_player_goods_by_uid(PlayerId, Location) ->	
    case ?DB_MODULE:select_all(goods, "*", [{uid, PlayerId}, {location, Location}]) of
        DataList when is_list(DataList) andalso length(DataList) >  0 ->
            Fun = fun(DataItem) ->
                          Info = list_to_tuple([goods|DataItem]),
						  Info
						  %%Info#goods{other = util:bitstring_to_term(Info#goods.other)}
                  end ,
            lists:map(Fun,DataList);
        _ ->
            []
    end .

%%删除物品
delete_goods(GoodsId) ->
	?DB_MODULE:delete(goods, [{id, GoodsId}]).

%%添加新物品
add_goods(GoodsInfo) ->   
	GoodsID = mod_id_global:get_id(goods),
	NewGoodsInfo = GoodsInfo#goods{id = GoodsID},
    ValueList = lists:nthtail(1, tuple_to_list(NewGoodsInfo)),
    FieldList = record_info(fields, goods),
	?DB_MODULE:insert(goods, FieldList, ValueList),
    GoodsID.

%% 获取物品ID的信息
%% 对要判断物品是否存在时查询
get_goods_by_id(GoodsId) ->
	?DB_MODULE:select_row(goods, "*",
								 [{id, GoodsId}],
								 [],
								 [1]).
%% 获取物品ID的信息(交易时批量查询)
get_goods_by_ids(GoodsIdList) ->
	?DB_MODULE:select_all(goods, "*", [{id, "in", GoodsIdList}]).

%% 更新物品信息
update_goods(Field, Data, Key, Value) ->
	?DB_MODULE:update(goods, Field, Data, Key, Value).

%% 获取所有同一种物品
select_all_same_goods(GTId) ->
    case ?DB_MODULE:select_all(goods, "*", [{gtid, GTId}]) of
        DataList when is_list(DataList) andalso length(DataList) >  0 ->
            [list_to_tuple([goods|DataItem]) || DataItem <- DataList];
        _ ->
            []
    end.  


%% 获取玩家的熔炼列表
get_player_smelt(PlayerId) ->	
    case ?DB_MODULE:select_all(player_smelt, "*", [{uid, PlayerId}]) of
        DataList when is_list(DataList) andalso length(DataList) >  0 ->
            Fun = fun(DataItem) ->
                          Info = list_to_tuple([player_smelt | DataItem]),
						  Info#player_smelt{smelt_list = util:bitstring_to_term(Info#player_smelt.smelt_list)}
                  end ,
            lists:map(Fun,DataList);
        _ ->
            []
    end .

%% 更新玩家的熔炼列表
update_player_smelt(PlayerSmelt) ->
	NewPlayerSmelt = PlayerSmelt#player_smelt{smelt_list = util:term_to_bitstring(PlayerSmelt#player_smelt.smelt_list)},
	ValueList = erlang:tl(erlang:tuple_to_list(NewPlayerSmelt)),
    ?DB_MODULE:replace(player_smelt, record_info(fields, player_smelt), ValueList).

%% ============================================
%% 获取道具控制信息
get_goods_control_info(ID) ->	
	case ?DB_MODULE:select_all(goods_control, "*", [{id, ID}]) of
		[Data | _] when is_list(Data) andalso length(Data) >  0 ->			
			Info = list_to_tuple([goods_control | Data]),
			Info#goods_control{goods_list = util:bitstring_to_term(Info#goods_control.goods_list)};		
		_ ->
			[]
	end .

%% 更新具控制信息
update_goods_control_info(GoodsControl) ->
	NewGoodsControl = GoodsControl#goods_control{goods_list = util:term_to_bitstring(GoodsControl#goods_control.goods_list)},
	ValueList = erlang:tl(erlang:tuple_to_list(NewGoodsControl)),
    ?DB_MODULE:replace(goods_control, record_info(fields, goods_control), ValueList).



