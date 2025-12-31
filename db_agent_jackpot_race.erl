%% @author Administrator
%% @doc @todo Add description to db_agent_jackpot_race.


-module(db_agent_jackpot_race).

-include("common.hrl").
-include("jackpot_race.hrl").



%% ====================================================================
%% API functions
%% ====================================================================
-export([
		 select_jackpot_race_room/1,
		 update_jackpot_race_room/1
		]).


%% ====================================================================
%% Internal functions
%% ====================================================================

%% 获取奖池赛房间信息
select_jackpot_race_room(RoomId) ->
	ValueList = ?DB_MODULE:select_row(?JACKPOT_DB, "*", [{room_id, RoomId}], [], [1]),
	case ValueList of
		[] ->
		    #jackpot_race_room{};
		_ ->
		    JackRace = list_to_tuple([?JACKPOT_DB|ValueList]),
			decode_jackpot_race_room(JackRace)
	end.

%% 更新运营活动数据
update_jackpot_race_room(JackRace) ->
    NewJackRace = encode_jackpot_race_room(JackRace),
    ValueList = erlang:tl(erlang:tuple_to_list(NewJackRace)),
    ?DB_MODULE:replace(?JACKPOT_DB, record_info(fields, ?JACKPOT_DB), ValueList).

encode_jackpot_race_room(Data) ->
	Data#jackpot_race_room{player_list = util:term_to_bitstring(Data#jackpot_race_room.player_list)
						  }.

decode_jackpot_race_room(Data) ->
	case util:bitstring_to_term(Data#jackpot_race_room.player_list) of
		PlayerList when is_list(PlayerList) -> ok;
		_ -> PlayerList = []
	end,
	Data#jackpot_race_room{player_list = PlayerList}.



