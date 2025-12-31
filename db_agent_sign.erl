%%%--------------------------------------
%%% @Module  : db_agent_sign
%%% @Author  : 
%%% @Created : 
%%% @Description:
%%%--------------------------------------
-module(db_agent_sign).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("sign.hrl").

-define(TABLE_NAME, player_sign1).
-define(RECORD_NAME, player_sign1).

-compile(export_all).


%% 获取玩家签到数据
get_player_sign_data(PlayerId) ->
	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
		[] ->
			init_data(PlayerId);
		ValueList ->
			Data = list_to_tuple([?TABLE_NAME|ValueList]),
			decode_data(Data)
	end.

%% 更新玩家奖励数据
update_player_sign(PlayerSign) ->
    PlayerSign1 = encode_data(PlayerSign),
    ValueList = erlang:tl(erlang:tuple_to_list(PlayerSign1)),
    ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

init_data(PlayerId) ->
	Data = #player_sign1{player_id=PlayerId},
	Data.

encode_data(Data) ->
	Data.

decode_data(Data) ->
	Data.

% %% 1.41版本签到代码，暂时废除
% %% 获取玩家签到数据
% get_player_sign_data(PlayerId) ->
% 	case ?DB_MODULE:select_row(?TABLE_NAME, "*", [{player_id, PlayerId}], [], [1]) of
% 		[] ->
% 			init_data(PlayerId);
% 		ValueList ->
% 			Data = list_to_tuple([?TABLE_NAME|ValueList]),
% 			decode_data(Data)
% 	end.

% %% 更新玩家奖励数据
% update_player_sign(PlayerSign) ->
%     PlayerSign1 = encode_data(PlayerSign),
%     ValueList = erlang:tl(erlang:tuple_to_list(PlayerSign1)),
%     ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

% init_data(PlayerId) ->
% 	Data = #player_sign{player_id=PlayerId, next_refresh_month=0},
% 	Data.

% encode_data(Data) ->
% 	String = util:term_to_string(Data#player_sign.state_list),
% 	Data#player_sign{state_list = String}.

% decode_data(Data) ->
% 	Term = util:bitstring_to_term(Data#player_sign.state_list),
%     Data#player_sign{state_list = Term}.