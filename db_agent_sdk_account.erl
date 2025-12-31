%%%--------------------------------------
%%% @Module  : db_agent_sdk_account
%%% @Author  : xws
%%% @Created : 2016.10.26
%%% @Description: sdk账号处理db
%%%--------------------------------------
-module(db_agent_sdk_account).
-include("common.hrl").
-include("record.hrl").
-include("debug.hrl").
-include("maimai_sdk.hrl").

-define(TABLE_NAME, sdk_account).
-define(RECORD_NAME, sdk_account).

-compile(export_all).

%% 加载sdk账号数据
load_all_sdk_account() ->
	case ?DB_MODULE:select_all_timeout(sdk_account, "*", [], infinity) of
		DataList when is_list(DataList) andalso length(DataList) >  0 ->
			[decode_data(list_to_tuple([sdk_account|DataItem])) || DataItem <- DataList];
		_ ->
			[]
	end.

%% 更新玩家账号数据
update_sdk_account(SdkAccount) ->
	EnSdkAccount = encode_data(SdkAccount),
    ValueList = erlang:tl(erlang:tuple_to_list(EnSdkAccount)),
    ?DB_MODULE:replace(?TABLE_NAME, record_info(fields, ?RECORD_NAME), ValueList).

%% 更新玩家账号数据
delete_sdk_account(UId) ->
    ?DB_MODULE:delete(?TABLE_NAME, [{uid, UId}]).

encode_data(Data) ->
	Data.

decode_data(Data) ->
	UId = erlang:binary_to_list(Data#sdk_account.uid),
	Account = erlang:binary_to_list(Data#sdk_account.account),
	PhoneNum = erlang:binary_to_list(Data#sdk_account.phone_num),
	Password = erlang:binary_to_list(Data#sdk_account.password),
	Device = erlang:binary_to_list(Data#sdk_account.device),
	DId = erlang:binary_to_list(Data#sdk_account.did),
	RegisterIp = erlang:binary_to_list(Data#sdk_account.register_ip),
	Data#sdk_account{
		uid = UId,
		account = Account,
		phone_num = PhoneNum,
		password = Password,
		device = Device,
		did = DId,
		register_ip = RegisterIp
	}.
