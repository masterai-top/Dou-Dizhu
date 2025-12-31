%%%-------------------------------------------------------------------
%%% @author henry
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Aug 2018 2:20 PM
%%%-------------------------------------------------------------------
-module(db_agent_pool_ctrl).
-author("henry").

-include("common.hrl").
-include("record.hrl").

%% API
-export([select_longhu_data/0,
    update_longhu_table/1,
    insert_longhu_table/1,
    select_longhu_data_count/0,
    select_rb_data/0,
    select_rb_data_count/0,
    insert_rb_table/1,
    update_rb_table/1
]).

select_longhu_data() ->
    [Data] = ?DB_MODULE:select_row(pool_ctrl, "info", [{id, 1}]),
    Data.

select_longhu_data_count() ->
    [Count] = ?DB_MODULE:select_count(pool_ctrl, [{id, 1}]),
    Count.

insert_longhu_table(Info) ->
    ?DB_MODULE:insert(pool_ctrl, [id, info], [1, Info]).

update_longhu_table(Info) ->
    ?DB_MODULE:update(pool_ctrl, [info], [Info], "id", 1).

select_rb_data() ->
    [Data] = ?DB_MODULE:select_row(pool_ctrl, "info", [{id, 2}]),
    Data.

select_rb_data_count() ->
    [Count] = ?DB_MODULE:select_count(pool_ctrl, [{id, 2}]),
    Count.

insert_rb_table(Info) ->
    ?DB_MODULE:insert(pool_ctrl, [id, info], [2, Info]).

update_rb_table(Info) ->
    ?DB_MODULE:update(pool_ctrl, [info], [Info], "id", 2).