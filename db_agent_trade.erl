%%%--------------------------------------
%%% @Module  : db_agent_trade
%%% @Author  :
%%% @Created :
%%% @Description: 商行处理模块
%%%--------------------------------------
-module(db_agent_trade).

-include("common.hrl").
-include("record.hrl").
-include("trade.hrl").

-define(TRADE_TABLE_NAME, trade).
-define(PLAYER_TABLE_NAME, player_trade).
-define(RECORD_NAME, trade_goods).
-define(PLAYER_RECORD_NAME, player_trade).


-compile(export_all).

%% 商行数据操作
%---------------------------------------
%% 获取所有商行数据
get_all_trade_goods() ->
	case ?DB_MODULE:select_all_timeout(?TRADE_TABLE_NAME, "*", [], 120000) of
		DataList when is_list(DataList) andalso length(DataList) >  0 ->
			Fun = fun(DataItem) ->
						  list_to_tuple([trade_goods|DataItem])
				  end ,
			lists:map(Fun, DataList);
		_ ->
			[]
	end.

%% 更新商行商品状态
update_trade_goods(TradeGoods) ->
    ValueList = erlang:tl(erlang:tuple_to_list(TradeGoods)),
    ?DB_MODULE:replace(?TRADE_TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

%% 移除商行商品
delete_trade_goods(TradeUId) ->
    ?DB_MODULE:delete(?TRADE_TABLE_NAME, [{trade_uid, TradeUId}]).

%% 移除所有商品
delete_all_trade_goods() ->
    ?DB_MODULE:delete(?TRADE_TABLE_NAME, []).

%% 移除所有玩家数据
delete_all_player_trade_data() ->
    ?DB_MODULE:delete(?PLAYER_TABLE_NAME, []).

%-----------------------------------
%%end


%% 玩家商行数据自身操作 
%-----------------------------------
%% 加载玩家商行数据
get_player_trade(PlayerId) ->
    case ?DB_MODULE:select_row(?PLAYER_TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
        [] ->
            init_data(PlayerId);
        ValueList ->
            Data = list_to_tuple([?PLAYER_RECORD_NAME|ValueList]),
            decode_player_trade(Data)
    end.

%% 更新玩家商行数据
update_player_trade(PlayerTrade) ->
    PlayerTrade1 = encode_player_trade(PlayerTrade),
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerTrade1)),
    ?DB_MODULE:replace(?PLAYER_TABLE_NAME, record_info(fields, ?PLAYER_RECORD_NAME), ValueList).

init_data(PlayerId) ->
    Data = #player_trade{player_id = PlayerId},
    Data1 = encode_player_trade(Data),
    ValueList = erlang:tl(erlang:tuple_to_list(Data1)),
    ?DB_MODULE:insert(?PLAYER_TABLE_NAME, record_info(fields, ?PLAYER_RECORD_NAME), ValueList),
    Data.


encode_player_trade(PlayerTrade) ->
    String = util:term_to_string(PlayerTrade#player_trade.trade_goods_list),
    PlayerTrade#player_trade{trade_goods_list = String}.

decode_player_trade(PlayerTrade) ->
    Term = util:bitstring_to_term(PlayerTrade#player_trade.trade_goods_list),
    PlayerTrade#player_trade{trade_goods_list = Term}.