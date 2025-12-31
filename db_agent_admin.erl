%% @author Administrator
%% @doc @todo Add description to db_agent_admin.


-module(db_agent_admin).

%% ====================================================================
%% API functions
%% ====================================================================
-compile(export_all).

%% ====================================================================
%% Internal functions
%% ====================================================================
-include("common.hrl").
-include("record.hrl").

%% 是否创建角色
is_create_visitor(Accname)->
    ?DB_MODULE:server_use(player, "id", [{acc_name, Accname},{acc_type, 0}], [], [1]).

