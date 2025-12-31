-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-09-15 17:56:48

local BaseCom = require_ex("data.BaseCom")
local M = class("DDZPlayCom" , BaseCom)

local paixing = {
    CARD_TYPE_NULL = 0, -- 没有出牌
    CARD_TYPE_WANG_ZHA = 1, -- 火箭
    CARD_TYPE_ZHA_DAN = 2, --炸弹
    CARD_TYPE_DAN_ZHANG = 3, -- 单张
    CARD_TYPE_SHUANG = 4, -- 双
    CARD_TYPE_SAN_ZHANG = 5, -- 三张
    CARD_TYPE_SAN_DAI_YI = 6, -- 三带一
    CARD_TYPE_SAN_DAI_ER = 7, -- 三带二
    CARD_TYPE_DAN_SHUN = 8, -- 单顺子
    CARD_TYPE_LIAN_DUI = 9, -- 连对
    CARD_TYPE_FEI_JI = 10, -- 飞机(3顺)
    CARD_TYPE_CHI_BANG1 = 11, -- 飞机带1(3顺)
    CARD_TYPE_CHI_BANG2 = 12, -- 飞机带2(3顺)
    CARD_TYPE_SI_DAN_ER1 = 13, -- 四带二(带单)
    CARD_TYPE_SI_DAN_ER2 = 14, -- 四带二(带双)
}
cc.exports.PaiXing = paixing

cc.exports.BIG_JOKER = 17
cc.exports.SMALL_JOKER = 16
cc.exports.ACE = 14
cc.exports.TWO = 15

cc.exports.DZ_MAOZI_TAG = 9801

local pokeOriPos = 75

local DDZ_Step = {
    NO_OPEN = 0,
    DIAL = 1,
    QIANG_DIZHU = 2,
    JIA_BEI = 3,
    DA_PAI = 4,
    POKE_END = 99,
}
cc.exports.DDZ_Step = DDZ_Step

local DDZ_OP_STATE = {
    OP_JDZ = 1,
    OP_QDZ = 2,
    OP_JB = 3,
    OP_MP = 4,
}
cc.exports.DDZ_OP_STATE = DDZ_OP_STATE

local isFirstPlay = true -- 是否是第一次玩斗地主,每次打开游戏都会重置

function M:ctor()
    BaseCom.ctor(self)

    self.m_pre = 0
    self.m_is_tips_higher = {}

    self:init()
end

function M:init()
   self._selectedPokeIdx = {}
   self._inTouchMode = false
   self._playUi = nil

   self._ready_enter = false
   self._beginPos = nil
   self._step = DDZ_Step.NO_OPEN
   self:addDDZNetEvent()

   self._pokeAction = nil       --判断是否是主动选择出牌或不出
end

function M:onEnter(callback,roomType)
    print("DDZPlayCom:onEnter()~~~~")
    local room_type = roomType or 0
    local playRoomId = Game.playerDB:getRoomId()
    --增加房间类型判断，兼容奖池赛
    if type(room_type)== "number" and room_type == DDZRoomType.JACKPOT_MATCH then
        if playRoomId and playRoomId > 0 then --断线重连不做任何操作

        else
            self:onEnterSelectRoom(DDZRoomType.JACKPOT_MATCH, 1201)
        end
    else
        local view = require_ex("games.ddz.views.DDZClassicUI"):new()
        Game:addLayer(view, 10)
    end

    if playRoomId and playRoomId > 0 then
        --self:enterRoom(0)
        Game.playerDB:setRoomId(0)
    end

    if callback then
        callback()
    end

    --用于新手引导进入斗地主游戏，防止热更新后无法进入
    if type(roomType) == "table" then
        self:enterReadyRoom(roomType[1])
    end
end

function M:onExit(callback)
    self:setPlayUi(nil)
    self:removeDDZNetEvent()
    Game.DDZPlayDB:clearOldData()
end

function M:getDB()
    return Game.DDZPlayDB
end

function M:setPlayUi(playUi)
    self._playUi = playUi
    self.m_pre = 0
end

function M:getPlayUi()
    return self._playUi
end

function M:getDDZEffc()
    if self._playUi then
        return self._playUi:getDDZEff()
    end
    return nil
end

--@ 斗地主广播
function M:addDDZNetEvent()
    self.eventIdTb = {}

    local function on16001(pack)
        Game.DDZNetCom:on16001(pack)
    end
    netCom.registerCallBack(16001, on16001, true)
    table.insert(self.eventIdTb,16001)

    local function on16002(pack)
        Game.DDZNetCom:on16002(pack)
    end
    netCom.registerCallBack(16002, on16002, true)
    table.insert(self.eventIdTb,16002)

    local function on16003(pack)
        Game.DDZNetCom:on16003(pack)
    end
    netCom.registerCallBack(16003, on16003, true)
    table.insert(self.eventIdTb,16003)

    local function on16004(pack)
        Game.DDZNetCom:on16004(pack)
    end
    netCom.registerCallBack(16004, on16004, true)
    table.insert(self.eventIdTb,16004)

    local function on16005(pack)
        Game.DDZNetCom:on16005(pack)
    end
    netCom.registerCallBack(16005, on16005, true)
    table.insert(self.eventIdTb,16005)

    local function on16006(pack)
        Game.DDZNetCom:on16006(pack)
    end
    netCom.registerCallBack(16006, on16006, true)
    table.insert(self.eventIdTb,16006)

    local function on16007(pack)
        Game.DDZNetCom:on16007(pack)
    end
    netCom.registerCallBack(16007, on16007, true)
    table.insert(self.eventIdTb,16007)

    local function on16008(pack)
        Game.DDZNetCom:on16008(pack)
    end
    netCom.registerCallBack(16008, on16008, true)
    table.insert(self.eventIdTb,16008)

    local function on16011(pack)
        Game.DDZNetCom:on16011(pack)
    end
    netCom.registerCallBack(16011, on16011, true)
    table.insert(self.eventIdTb,16011)

    local function on16012(pack)
        Game.DDZNetCom:on16012(pack)
    end
    netCom.registerCallBack(16012, on16012, true)
    table.insert(self.eventIdTb,16012)

    local function on16013(pack)
        Game.DDZNetCom:on16013(pack)
    end
    netCom.registerCallBack(16013, on16013, true)
    table.insert(self.eventIdTb,16013)

    local function on16014(pack)
        Game.DDZNetCom:on16014(pack)
    end
    netCom.registerCallBack(16014, on16014, true)
    table.insert(self.eventIdTb,16014)

    local function on16016(pack)
        Game.DDZNetCom:on16016(pack)
    end
    netCom.registerCallBack(16016, on16016, true)
    table.insert(self.eventIdTb,16016)

    local function on16018(pack)
        Game.DDZNetCom:on16018(pack)
    end
    netCom.registerCallBack(16018, on16018, true)
    table.insert(self.eventIdTb,16018)

    local function on16019(pack)
        Game.DDZNetCom:on16019(pack)
    end
    netCom.registerCallBack(16019, on16019, true)
    table.insert(self.eventIdTb,16019)

    local function on16020(pack)
        Game.DDZNetCom:on16020(pack)
    end
    netCom.registerCallBack(16020, on16020, true)
    table.insert(self.eventIdTb,16020)

    local function on16021(pack)
        Game.DDZNetCom:on16021(pack)
    end
    netCom.registerCallBack(16021, on16021, true)
    table.insert(self.eventIdTb,16021)

    local function on16022(pack)
        Game.DDZNetCom:on16022(pack)
    end
    netCom.registerCallBack(16022, on16022, true)
    table.insert(self.eventIdTb,16022)

    local function on16023(pack)
        Game.DDZNetCom:on16023(pack)
    end
    netCom.registerCallBack(16023, on16023, true)
    table.insert(self.eventIdTb,16023)

    local function on16026(pack)
        Game.DDZNetCom:on16026(pack)
    end
    netCom.registerCallBack(16026, on16026, true)
    table.insert(self.eventIdTb,16026)

    local function on16028(pack)
        Game.DDZNetCom:on16028(pack)
    end
    netCom.registerCallBack(16028, on16028, true)
    table.insert(self.eventIdTb,16028)

    local function on16029(pack)
        Game.DDZNetCom:on16029(pack)
    end
    netCom.registerCallBack(16029, on16029, true)
    table.insert(self.eventIdTb,16029)

    local function on16032(pack)
        Game.DDZNetCom:on16032(pack)
    end
    netCom.registerCallBack(16032, on16032, true)
    table.insert(self.eventIdTb,16032)

    local function on16033(pack)
        Game.DDZNetCom:on16033(pack)
    end
    netCom.registerCallBack(16033, on16033, true)
    table.insert(self.eventIdTb,16033)

    local function on16035(pack)
        Game.DDZNetCom:on16035(pack)
    end
    netCom.registerCallBack(16035, on16035, true)
    table.insert(self.eventIdTb,16035)

    local function on16040(pack)
        Game.DDZNetCom:on16040(pack)
    end
    netCom.registerCallBack(16040,on16040,true)
    table.insert(self.eventIdTb,16040)
end

--移除监听事件
function M:removeDDZNetEvent()
    for k,v in ipairs(self.eventIdTb) do
        netCom.unRegisterCallBack(v)
    end
    self.eventIdTb = {}
end

function M:isFirstPokerGame()
    return (Game.playerDB:getwinNum() + Game.playerDB:getloseNum()) == 0
            and Game.playerDB:isInit()
end

function M:getDDZUIRefresh()
    if self._playUi then
        return self._playUi:getDDZUIRefresh()
    end
    return nil
end

function M:isTipsHigher(next_id)
    if self.m_is_tips_higher[next_id] == nil then
        return true
    end
    return self.m_is_tips_higher[next_id]
end

function M:setIsTipsHigher(next_id, is_tips)
    self.m_is_tips_higher[next_id] = is_tips
end

-- 进入游戏房间请求
function M:enterRoom(roomId, bNeedCheck, is_upgrade, is_lower)
    Game.DDZPlayDB:setRoomType(RoomConfig.type(roomId))
    local tab = {
        function(cb)
            if bNeedCheck then
                local needCoin = Game.DDZPlayDB:getDDZLimitMin(roomId) or 0
                Game:GetCom(Model.CHARGE):checkCoinEnough(needCoin, RechargeType.Poker, cb, roomId)
            else
                cb()
            end
        end,
        function(cb)
            local needCoin = Game.DDZPlayDB:getDDZLimitMin(roomId) or 0
            local player_coin = Game.playerDB:getPlayerCoin()
            if player_coin < needCoin then
                Log(LOG.TAG.DDZ, LOG.LV.WARN, "============enter Room player_coin less===============")
                if Game:getScenceIdx() ~= SCENCE_ID.PLATEFORM then
                    Game:openGameWithIdx(SCENCE_ID.PLATEFORM)
                end
                return
            end
            Game.DDZNetCom:req16000(roomId, is_upgrade, is_lower)
        end
    }
    common_util.series(tab)
end

--加入游戏准备界面 : is_quickStart 是否快速开始
function M:enterReadyRoom(roomId, bNeedCheck,is_upgrade, is_lower, is_quickStart)
    Game.DDZPlayDB:setRoomType(RoomConfig.type(roomId))
    local tab = {
        function(cb)
            if bNeedCheck then
                local needCoin = Game.DDZPlayDB:getDDZLimitMin(roomId) or 0
                Game:GetCom(Model.CHARGE):checkCoinEnough(needCoin, RechargeType.Poker, cb, roomId)
            else
                cb()
            end
        end,
        function(cb)
            -- local needCoin = RoomConfig.limit_min(roomId) or 0
            -- local player_coin = Game.playerDB:getPlayerCoin()
            -- if player_coin < needCoin then
            --     Log(LOG.TAG.DDZ, LOG.LV.WARN, "============enter Room player_coin less===============")
            --     if Game:getScenceIdx() ~= SCENCE_ID.PLATEFORM then
            --         Game:openGameWithIdx(SCENCE_ID.PLATEFORM)
            --     end
            --     return
            -- end

            Game.DDZPlayDB:setRoomType(RoomConfig.type(roomId))
            Game.DDZPlayDB:setRoomId(roomId)
            if Game:getScenceIdx() ~= SCENCE_ID.DDZ then
                Game:openGameWithIdx(SCENCE_ID.DDZ)
            end
            Game.recommendCom:showCoinWinLoseTips()
            --显示准备状态的桌面
            if self._playUi and (not tolua.isnull(self._playUi)) then  --容错 add by yaoyurong
                self._playUi:showReadyView(roomId,is_upgrade, is_lower, is_quickStart)
            end
        end
    }
    common_util.series(tab)
end

--升场玩游戏
function M:enterHigherRoom()
    local curRoomID = Game.DDZPlayDB:getRoomId()
    local needCoin = Game.DDZPlayDB:getDDZLimitMin(curRoomID)    --当前房间要求的最低金币
    local curCoin = Game.playerDB:getPlayerCoin()
    local can_start = (curCoin >= needCoin)
    local ret = false
    if can_start then
        local uid = Game.playerDB:getPlayerUid()
        local nexRoomID = (curRoomID+1)
        local limitMax = Game.DDZPlayDB:getDDZLimitMax(curRoomID)
        if limitMax ~= 0 and curCoin >= limitMax then   --判断是否高于下个房间能支持的最大金币数，如是则随机选取高等房间
            ret = true
            self:playerLeave(function() self:fastEnterRoom(true, false, true) end)
        elseif RoomConfig[nexRoomID] then   --否则进入下一等级房间
            ret = true
            self:playerLeave(function() self:enterRoom(nexRoomID, false, true) end)
        end
    end
    return ret
end

--降场玩游戏
function M:enterLowerRoom()
    local ret = false
    if Game.recommendCom:isCanBaseGoon() then
        ret = true
        self:playerLeave(function()
            self:fastEnterRoom(false, false, false,true)
        end)
    else
        local is_show_first = Game.rechargeCom:isShowFirstRecharge()
        if is_show_first then
            Game.rechargeCom:showFirstRecharge()   --打开首充界面
        else
            self:openDDZRecharge()
        end
    end
    return ret
end

function M:enterPokerGame(roomId)
    local type = RoomConfig.type(roomId)
    if type == 1
        or type == 2
        or type == 4
        or type == 5 
        or type == 11 then
        self:enterReadyRoom(roomId)
    else
        Game.DDZPlayDB:setRoomType(DDZRoomType.CLASSIC)
        Game.DDZPlayCom:fastEnterRoom(false, false, false)
    end
end

function M:fastEnterRoom(hasinRoom, bNeedCheck, is_upgrade, is_lower)
    local tab = {
        -- 取消旧补偿检测
        function(cb)
            if bNeedCheck then
                local roomType = Game.DDZPlayDB:getRoomType()
                local roomBaseID = roomType * 100 + 1
                local needCoin = Game.DDZPlayDB:getDDZLimitMin(roomBaseID)
                Game:GetCom(Model.CHARGE):checkCoinEnough(needCoin, RechargeType.Poker, cb)
            else
                if cb then cb() end
            end
        end,
        function(cb)
            local player_coin = Game.playerDB:getPlayerCoin()
            local roomType = Game.DDZPlayDB:getRoomType()
            local roomBaseID = 0
            if roomType == 1 then
                roomBaseID = roomType * 100 + 1
            elseif roomType == 2 then
                roomBaseID = roomType * 100 + 2 --癞子场基本房为202
            elseif roomType == 11 then
                roomBaseID = roomType * 100 + 1
            elseif roomType == 12 then
                roomBaseID = roomType * 100 + 1
            end
            if not RoomConfig[roomBaseID] then
                Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===fast EnterRoom roomBaseID error roomType is: " .. (roomType))
                return
            end

            if hasinRoom == true and player_coin < Game.DDZPlayDB:getDDZStartMin(roomBaseID) then
                Log(LOG.TAG.DDZ, LOG.LV.WARN, "===fast EnterRoom roomType is: " .. roomType)
                Game:tipMsg("金币不足，无法快速开始游戏", 1, nil, function()
                    Game.DDZPlayCom:gameBack()
                end)
                return
            end

            local roomID = 0
            local roomIds = RoomConfig.getIds()
            table.sort(roomIds, function(v1, v2)
                return v1 > v2
            end)

            for _, id in ipairs(roomIds) do
                if tonumber(RoomConfig.type(id)) == roomType then
                    if player_coin >= Game.DDZPlayDB:getDDZLimitMin(id) then
                        roomID = id
                        break
                    end
                end
            end

            if roomID == 0 then
                Log(LOG.TAG.DDZ, LOG.LV.WARN, "===fast EnterRoom can not enter=========")
                if hasinRoom == true then
                    Game:tipMsg("金币不足，无法快速开始游戏", 2, nil, function()
                        Game.DDZPlayCom:gameBack()
                    end)
                else
                    Game:tipMsg("金币不足，无法快速开始游戏", 2)
                end
                return
            end
            if roomID == 204 then
                roomID = 203
            end

            if is_upgrade then
                self:enterReadyRoom(roomID, false, true, false, true)

            elseif is_lower then
                self:enterReadyRoom(roomID, false, false, true, true)
            else
                self:enterReadyRoom(roomID, false, false, false, true)
            end
        end
    }
    common_util.series(tab)
end

function M:enterOnActivity(id)
    local player_coin = Game.playerDB:getPlayerCoin()
    if not RoomConfig[id] or player_coin < Game.DDZPlayDB:getDDZLimitMin(id) then
        Game.rechargeCom:showWhetherRecharge(nil, "金币不足，是否充值？", nil, nil, "Coin")
        return
    end
    self:enterRoom(id, false)
end

function M:enterOnLackCoin(rid)
    local player_coin = Game.playerDB:getPlayerCoin()
    local roomType = Game.DDZPlayDB:getRoomType()
    local roomBaseID = roomType * 100 + 1
    if not RoomConfig[roomBaseID] then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===enter OnLackCoin roomBaseID error roomType is: " .. (roomType))
        return
    end
    if player_coin < Game.DDZPlayDB:getDDZStartMin(roomId) then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===enter OnLackCoin roomType is: " .. roomType)

        local successCb = function()
            self:fastEnterRoom(true, false, false)
        end
        local failCb = function()
            Game:openGameWithIdx(SCENCE_ID.PLATEFORM)
        end
        Game:GetCom(Model.CHARGE):handleLackCoinWindows(rid, successCb, failCb)
        Game:tipMsg("金币不足，请购买礼包继续游戏", 2)
        return
    end
    local roomID = 0
    local roomIds = RoomConfig.getIds()
    table.sort(roomIds, function(v1, v2)
        return v1 > v2
    end)

    for _, id in ipairs(roomIds) do
        if tonumber(RoomConfig.type(id)) == roomType then
            if player_coin >= Game.DDZPlayDB:getDDZLimitMin(id) then
                roomID = id
                break
            end
        end
    end
    if roomID == 0 then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===enter OnLackCoin can not enter=========")

        local successCb = function()
            self:fastEnterRoom(true, false, false)
        end
        local failCb = function()
            Game:openGameWithIdx(SCENCE_ID.PLATEFORM)
        end
        Game:GetCom(Model.CHARGE):handleLackCoinWindows(rid, successCb, failCb)
        Game:tipMsg("金币不足，请购买礼包继续游戏", 2)
        return
    end
    self:enterRoom(roomID, false)
end

function M:onMatchReadyToStart(room_id)
    self._ready_enter = true

    Game.DDZPlayDB:setRoomId(room_id)
    if Game:getScenceIdx() ~= SCENCE_ID.DDZ then
        Game:openGameWithIdx(SCENCE_ID.DDZ)
    end
    Game.DDZPlayCom:setStep(DDZ_Step.NO_OPEN)
    Game.DDZPlayDB:clearDoubleInfo()

    Game.recommendCom:onGameClicked(room_id)
    self:getPlayUi():onCreateReadyRole(0)
    self:getPlayUi():showMatchRoomReadyButton()
end

function M:onHeroRankMatchReadyToStart(room_id, role_list)
    self._ready_enter = true

    Game.DDZPlayDB:setRoomId(room_id)
    if Game:getScenceIdx() ~= SCENCE_ID.DDZ then
        Game:openGameWithIdx(SCENCE_ID.DDZ)
    end
    Game.DDZPlayCom:setStep(DDZ_Step.NO_OPEN)
    Game.DDZPlayDB:clearDoubleInfo()

    Game.recommendCom:onGameClicked(room_id)

    local role = role_list[1]
    self:getPlayUi():onCreateReadyRole(role.id)
    self:getPlayUi():showMatchRoomReadyButton()

    local onUseCallback = function()
        Game.DDZPlayDB:setRoomType(RoomConfig.type(room_id))
        Game.DDZPlayCom:enterRoom(room_id)
    end
    performWithDelay(self:getPlayUi(), function()
        Game.bagCom:onUse(0, role.g_id, 0, 0, PropUseType.equip, onUseCallback)
    end, 5.0)
end

function M:onEnterSelectRoom(room_type, room_id)
    print("===========onEnterSelectRoom=======")
    if Game.DDZPlayDB and Game.DDZPlayDB:isInPlaying() then
        local str = string.format("您正在斗地主牌局中，点击确定继续牌局")
        local modalDialog = require_ex("ui.common.ModalDialog").new()
        local param = {
            callback1 = function()
                modalDialog:destroy()
            end,
            callback2 = function()
                Game.DDZPlayCom:enterRoom(0)
                modalDialog:destroy()
            end,
            content = str
        }
        modalDialog:init(param):addToScene()
    else
        local playerRoomId = Game.playerDB:getRoomId()
        if playerRoomId ~= 0 then --表示有重连，直接返回不做任何操作
            return
        end
        local needCoin = Game.DDZPlayDB:getDDZLimitMin(room_id)
        local maxCoin = Game.DDZPlayDB:getDDZLimitMax(room_id)
        local player_coin = Game.DDZPlayDB:getDDZCoinNum(room_id)
        if room_type == DDZRoomType.JACKPOT_MATCH then
            if player_coin < needCoin then
                Game.rechargeCom:openRechargeView("Coin")
                return
            end
            Game.DDZPlayDB:setRoomType(room_type)
            Game.DDZPlayCom:enterReadyRoom(room_id, false)
            Game.recommendCom:handleHud(room_id)
        else
            local bank_coin = Game.safeboxDB:getBankCoin()
            maxCoin = maxCoin == 0 and player_coin + 1 or maxCoin
            if (player_coin + bank_coin) < needCoin and not IS_IOS_TS then
                local stage = room_id % 100
                if stage == 1 and player_coin < 1000 and Game.rechargeDB:canGetSystemAward() then
                    require_ex("ui.common.SystemAssistUI").new():addToScene(UIZorder.Dialog)
                else
                    self:openDDZRecharge(room_id)
                end
                return
            end

            if player_coin > maxCoin then
    			-- 统一高级场跳转引导样式 add by xcw
                local fitRoomId = 0
                local ids = RoomConfig:getIds()
                table.sort(ids, function(v1, v2)
                    return v1 > v2
                end)
                for _,id in ipairs(ids) do
                    if (room_type == RoomConfig.type(id)) and (id > room_id) then
                        if player_coin >= Game.DDZPlayDB:getDDZLimitMin(id) then
                            fitRoomId = id
                            break
                        end
                    end
                end
                local roomNameTb = {"初级场","中级场","高级场","顶级场"}
                if fitRoomId ~= 0 then
                    local roomName = roomNameTb[fitRoomId%100]
                    local modalDialog = require_ex("ui.common.ModalDialog").new()
                    local param = {
                        callback1 = function()
                            if modalDialog and modalDialog.destroy then
                                modalDialog:destroy()
                            end
                        end,
                        callback2 = function()
                            if modalDialog and modalDialog.destroy then
                                modalDialog:destroy()
                            end
                            Game.DDZPlayCom:onRoomFastStart(room_type)
                        end,
                        upgrade = {roomName = roomName}
                    }
                    modalDialog:init(param):addToScene()
                    modalDialog:setButtonText(2, "快速开始")
                end
                return
            end
            if player_coin < needCoin then --此时已满足bank_coin>0
                -- local str = string.format("当前还缺%d金币可以进入游戏，请从银行里取出对应金币",needCoin-player_coin)
                -- if IS_IOS_TS then -- ios提审不能出现保险箱字样
                --     str = string.format("您还缺%d金币可进入房间",needCoin-player_coin)
                -- end
                -- Game:tipMsg(str,2,nil,nil,nil,2)
                if not IS_IOS_TS then
                    local minCoin = Game.DDZPlayDB:getDDZLimitMin(room_id)
                    local bankCoin = Game.safeboxDB:getBankCoin()
                    local modalDialog = require_ex("ui.common.ModalDialog").new()
                    local param = {
                        content = string.format("金币不足%d，您的银行存有%d金币，是否前往银行？", minCoin, bankCoin),
                        callback1 = function()
                            if modalDialog and modalDialog.destroy then
                                modalDialog:destroy()
                            end    
                            -- Game:openGameWithIdx(SCENCE_ID.PLATEFORM, pushCmd)
                        end,
                        callback2 = function()
                            if modalDialog and modalDialog.destroy then
                                modalDialog:destroy()
                            end
                            Game.safeboxCom:openSafeboxUI() 
                        end,
                    }
                    modalDialog:init(param):addToScene()
                    modalDialog:setButtonText(1, "返回")
                    modalDialog:setButtonText(2, "立即前往")
                end
                return
            end
            Game.DDZPlayDB:setRoomType(room_type)
            Game.DDZPlayCom:enterReadyRoom(room_id, false)
            Game.recommendCom:handleHud(room_id)
        end
    end
end

function M:onEnterGameRoom(info)
    if info.roomid ~= 0 then
        Game.DDZPlayDB:setRoomId(info.roomid)
    end
    if Game:getScenceIdx() == SCENCE_ID.DDZ then
        Game:showWaitUI("", WAIT_TYPE.RUN_ANI)
        Game:onEvent(DDZEvent.DDZ_ON_CHG_TASK, {})
        return
    end
    self._ready_enter = false
    Game:showWaitUI("", WAIT_TYPE.RUN_ANI)
    Game:onEvent(DDZEvent.DDZ_ON_CHG_TASK, {})
end

function M:onWaitStartGame(info)
    Game:destroyDDZWaitUI()
    if Game:getScenceIdx() ~= SCENCE_ID.DDZ then
        Game:openGameWithIdx(SCENCE_ID.DDZ)
    end

    Game.DDZPlayCom:setStep(DDZ_Step.NO_OPEN)
    Game.DDZPlayDB:setDDZPlayers(info.players)
    Game.DDZPlayDB:clearDoubleInfo()

    -- local uid = Game.playerDB:getPlayerUid()
    -- local is_first = false
    -- for i,v in ipairs(info.players or {}) do
    --     if uid == v.uid then
    --         is_first = ((v.win_num+v.lose_num) == 0)
    --         break
    --     end
    -- end
    if self._ready_enter then return end
    Game:showWaitUI(stringCfgCom.content("ddz_wait_start"), WAIT_TYPE.RUN_ANI,function()
        Game.DDZNetCom:req16033()  --如未匹配成功退出
    end)
end

function M:onStartGame(info)
    Game:destroyDDZWaitUI()
    Game.DDZPlayDB:clearOldData()

    -- if isFirstPlay then
        -- 如果是本次打开app第一次玩斗地主,需要显示提示信息
        -- isFirstPlay = false
        if self:getPlayUi() then
            -- self:getPlayUi():showTips(SubGamesNameConfig.name(1).."场可赢得更多红包")
            local num = Game.playerDB:getDiamond()/100
            local str = string.format("|当前红包,22,#FFFFFF,#38033B|%.2f,22,#FFD145,#38033B|元(满10元可兑换),22,#FFFFFF,#38033B|",num)
            -- print("~~~~~~~~~~~~~~~~~~ "..str)
            self:getPlayUi():showTips(str,true)
        end
    -- end

    local view1 = Game.uiManager:getLayer("DDZMatchWait")
    local view2 = Game.uiManager:getLayer("MatchingView")
    if view1 then view1:closeView() end
    if view2 then view2:closeView() end


    local myUid = Game.playerDB:getPlayerUid()
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("myUid is:%s", tostring(myUid)))

    local tableInfo = info.table_info
    local players = tableInfo.players
    local diPokes = tableInfo.table_cards
    local lzPokes = tableInfo.laizi_cards

    local cards_map = {}
    local landLordPos = nil
    for k,v in ipairs(players or {}) do
        local uid = v.uid
        if uid == myUid then
            Game.DDZPlayDB:setMyPos(v.pos)
            Game.DDZPlayDB:setMyUseNote(v.use_note)
        end
        if v.station == 2 then
            landLordPos = v.pos
        end
        cards_map[v.pos] = v.cards_num

        Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("pos %d, uid is:%s", v.pos, tostring(uid)))
    end
    local is_new_game = true
    Game.DDZPlayDB:setRoomId(tableInfo.roomid)
    -- if not Game.DDZPlayDB:getIsMatchRoom() then
    --     Game.recommendCom:onGameJoin(tableInfo.roomid)
    --     Game.recommendCom:onGameClicked(tableInfo.roomid)
    -- else
    --     Game.recommendCom:onGameJoin(tableInfo.roomid)
    -- end

    if Game:getScenceIdx() ~= SCENCE_ID.DDZ then
        is_new_game = false
        Log(LOG.TAG.DDZ, LOG.LV.INFO, "====on 16002 play ui is null====")

        Game:openGameWithIdx(SCENCE_ID.DDZ)


        Game.DDZPlayDB:setDDZPlayers(players)
        Game.DDZPlayCom:onGetPlayPokes(tableInfo.cards)
        Game.DDZPlayCom:startSendPokes(true)

        local build16004 = Game.DDZNetCom:build16004From16002(info)
        Game.DDZPlayCom:onTableStateChange(build16004)

        for k,v in pairs(cards_map) do
            Game.DDZPlayDB:setPlayerPokeNum(k, v)
        end
        local isTuoGuan = Game.DDZPlayDB:isTuoguan()
        Game.DDZPlayCom:setTuoGuanMaskPoke(isTuoGuan)
    else
        Game.DDZPlayDB:setDDZPlayers(players)
    end
    if #tableInfo.cards > 0 then
        local pokesData = Game.DDZPlayDB:getPokesData()
        if pokeData == nil then
            Game.DDZPlayCom:onGetPlayPokes(tableInfo.cards)
        end
        local data = {pos = Game.DDZPlayDB:getMyPos()}
        self:getPlayUi():onPokerInfoRefresh(data)
    end
    self:getPlayUi():clearDiZhuMao()
    self:getPlayUi():onDDZ16002(info)

    if tableInfo.state == 4 then
        Game.DDZPlayCom:setJiPaiQiBunttonVisible(false)
    else
        Game.DDZPlayCom:setJiPaiQiBunttonVisible(true)
    end
    if landLordPos ~= nil then
        Game.DDZPlayCom:onLandLordPos(landLordPos)
    end

    if Game.DDZPlayDB:getIsMatchRoom() then
        Game.DDZPlayCom:refreshMatchTurnInfo(tableInfo.roomid)
        self:getPlayUi():backToInit()

    elseif Game.DDZPlayDB:getIsLaiZiRoom() then
        local laiziNum = tableInfo.laizi_cards[1]
        Game.DDZPlayCom:onGetLaiZiPokes(laiziNum)
    end
    Game.DDZPlayCom:onPokeNumChange()
    Game.DDZPlayDB:setDoublesInfo(tableInfo.doubles)

    -- is_new_game
    if #diPokes == 0 then
        Game.DDZPlayCom:onEvent(DDZEvent.DDZ_NEW_GAME_EVENT, {is_new_game})
    else
        Game.DDZPlayDB:setDiPai(diPokes, lzPokes)
        Game.DDZPlayCom:onChangePlayerDiPai(false)
    end

    Game.DDZPlayDB:usePokes(tableInfo.use_cards)

    --[[
    local actList = {}
    for i=1,3 do
        local actNode = {id = DDZ.ACT_DAIJI, pos = i}
        table.insert(actList, actNode)
    end
    self:getPlayUi():onDoPlayerActor(actList)
    --]]
    print("===============onStartGame==================")

    if self.m_pre ~= 0 and self.m_pre < tableInfo.roomid then
        -- Game:tipMsg("恭喜您进入更高场次！", 2)
        local ddzEffect = self:getDDZEffc()
        if ddzEffect and ddzEffect.showUpgradeEffect then
            ddzEffect:showUpgradeEffect(self._playUi)
        end
        self.m_pre = tableInfo.roomid
    else
        self.m_pre = tableInfo.roomid
    end
    Game.activityCom:reqCommonActList()
end

-- 确定地主
function M:onLandLordPos(landLordPos)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===onLandLordPos play ui is null===")
        return
    end
    Game.DDZPlayDB:setLandLordPos(landLordPos)
    self:getDDZEffc():effBreakConnetDZ(landLordPos)
end

-- 获得手牌
function M:onGetPlayPokes(cards)
    Game.DDZPlayDB:initPokeData(cards)
end

function M:onGetLaiZiPokes(laiziNum)
    if not laiziNum then
        return
    end
    Game.DDZPlayDB:setLaiZiPoke(laiziNum)
end

-- 牌局状态变化
function M:onTableStateChange(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===onTableStateChange play ui is null===")
        return
    end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===on 16004 onTableStateChange ===")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, info)
    local statePos = info.state_pos
    local stateTime = info.state_time
    local isFirstDZ = (info.round_state == 0)
    local isMe = Game.DDZPlayDB:isMyPos(statePos)

    -- 0 没有上家牌, 1 有上家牌
    Game.DDZPlayDB:setRoundState(info.round_state)
    -- 2:抢地主，3:加倍，4:打牌
    local state = info.state
    if state == 2 then
        Game.DDZPlayCom:setStep(DDZ_Step.QIANG_DIZHU)

    elseif state == 3 then
        local my_pos = Game.DDZPlayDB:getMyPos()
        Game.DDZPlayCom:setStep(DDZ_Step.JIA_BEI)

    elseif state == 4 then
        -- Game.DDZPlayCom:setStep(DDZ_Step.DA_PAI)
    end
    self:getDDZUIRefresh():on16004(info)
end

-- 玩家出牌回调，包括自己
function M:onPlayCards(info, ignoreJPQ)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===onPlayCards play ui is null===")
        return
    end
    local retCode = info.ret_code
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("======on 16006 player play card retCode %d========", retCode))
    Log(LOG.TAG.DDZ, LOG.LV.INFO, info)

    if retCode ~= 0 then
        Game.DDZPlayCom:errorHandle(retCode)

        --暂时去掉 有可能有更好的解决方法 edit by cxh 2018-5-24
        --有可能出现玩家出牌 但是服务器还没收到就已经处理了超时自动出牌的情况
        --将原来出出去的牌 放回牌堆
        -- if tonumber(retCode) == 16000014 then
        --     if info.pos == 0 then--牌局结束了 不用管了
        --         return
        --     end

        --     print("产生16000014错误码，将牌放回手牌")
        --     if Game.DDZPlayDB:getIsLaiZiRoom() then
        --         Game.DDZPlayDB:onPokeDataChange(1, info.cards, info.pos, true)
        --     else
        --         Game.DDZPlayDB:onPokeDataChange(1, info.cards, info.pos)
        --     end

        --     Game.DDZPlayCom:onPokeNumChange()
        --     Game.DDZPlayCom:setJiPaiQiBunttonVisible(false)
        --     Game.DDZPlayCom:onChangeJPQUI()
        -- end

        return
    end

    local pos = info.pos
    local cards = info.cards
    local lzCards = info.laizis

    local realCards = nil
    if #lzCards > 0 then
        local dataClone = table.newclone(cards)
        local mapLaiZi = Game.DDZUtil:buildLZMap(lzCards)

        for k,v in pairs(dataClone) do
            if mapLaiZi[v] ~= nil then
                dataClone[k] = mapLaiZi[v]
            end
        end
        realCards = dataClone
    else
        realCards = cards
    end
    if not Game.DDZPlayDB:isMyPos(pos) then
        if #lzCards > 0 then
            Game.DDZPlayDB:setRoundPokes(realCards, true)
        else
            if #cards > 0 then
                Game.DDZPlayDB:setRoundPokes(realCards)
            end
        end
    else
        local isClassic = Game.DDZPlayDB:getIsClassicRoom()
        local isWithoutWashRoom = Game.DDZPlayDB:getIsWithoutWashRoom()
        if isClassic or isWithoutWashRoom then
            Game.DDZPlayDB:setLastMyGoPokeType(nil)
            local isWangZha = Game.DDZPlayCom:checkWangZhaPoke(cards)
            if isWangZha then
                Game.DDZPlayDB:setLastMyGoPokeType(PaiXing.CARD_TYPE_WANG_ZHA)
            end

            if #cards > 0 then
                Game.DDZPlayDB:addPlayRound()
            end
        end
    end

    if not ignoreJPQ then
        Game.DDZPlayDB:onPokeDataChange(0, cards, pos)
        Game.DDZPlayCom:onPokeNumChange()
        Game.DDZPlayDB:usePokes(info.cards)
    end

    info.showPoke = self._pokeAction
    --if not Game.DDZPlayDB:isMyPos(pos) then   --不是自己出牌需要通知
        self:getPlayUi():onDDZ16006(info)
    --elseif self._pokeAction == nil then       --地主一开始出牌就超时托管
    --    self:getPlayUi():onDDZ16006(info)
    --end

    if #cards > 0 then
        local actList = {}
        local actNode = {id = DDZ.ACT_CHUPAI, pos = pos}
        table.insert(actList, actNode)

        --self:getPlayUi():onDoPlayerActor(actList)
    end
    if #realCards > 0 then
        local data = Game.DDZPlayCom:converSvrPokeToClient(realCards)
        local type, beginNum = Game.DDZPlayCom:getPokeType(data)
        Game.DDZPlayCom:getDDZEffc():playTypePokeEffect(type, pos, beginNum)
        Game.DDZPlayCom:getDDZEffc():playPokeEff(type)
    else
        Game.DDZPlayCom:getDDZEffc():playTypePokeEffect(PaiXing.CARD_TYPE_NULL, pos)
    end
    Game.connectHandler:setHeartBeatInterval(HEART_BEAT_DEFAULT)
    self._pokeAction = nil
end

--出牌动画
function M:onPlayCardsAni(endCb)
    local selectedCards = Game.DDZPlayDB:getSelectedPoke()
    if selectedCards and #selectedCards > 0 then
        for k,v in pairs(selectedCards) do
            local poke = Game.DDZPlayDB:getOnePokeWithIndex(v)
            if poke then
                local pokeView = poke.pokeView
                -- 缩短出牌动画时间，动画结束后调用1次回调 add by xuchenwei 
                local seq = cc.Sequence:create(cc.MoveBy:create(0.03,cc.p(0,20)),cc.FadeOut:create(0.01),cc.CallFunc:create(function()
                    if k == #selectedCards and endCb then                  
                        endCb()
                    end
                end))
                pokeView:runAction(seq)
            end
        end
    end
end

function M:onPlayGameEnd(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===onPlayGameEnd play ui is null===")
        return
    end
    Game.DDZPlayCom:setStep(DDZ_Step.POKE_END)
    Game.DDZPlayCom:setJiPaiQiBunttonVisible(true)
    self:getPlayUi():showExitGamebutton(false)
    self:getPlayUi():setTuoguanSelected(false)

    local isMatchRoom = Game.DDZPlayDB:getIsMatchRoom()
    if isMatchRoom then return end

    self:getPlayUi():on16008(info)
end

function M:onWaitShowGameResult(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===onWaitShowGameResult play ui is null===")
        return
    end
    Game.DDZPlayDB:onGameEnd(info)

    local is_win = false
    local winner = info.winner or 0
    if Game.DDZPlayDB:isLandLord() then
        if winner == 2 then
            is_win = true
            Game:GetModel(Model.PLAYER):addWinCount()
        else
            Game:GetModel(Model.PLAYER):addLoseCount()
        end
    else
        if winner == 2 then
            Game:GetModel(Model.PLAYER):addLoseCount()
        else
            is_win = true
            Game:GetModel(Model.PLAYER):addWinCount()
        end
    end
    if is_win then
        Game:GetModel(Model.TASK):onTaskCompAdd(Game.DDZPlayDB:getDDZTaskScene())
    end

    -- local actList = {}
    -- local allPlayer = Game.DDZPlayDB:getAllPlayer()
    -- for k,v in pairs(allPlayer) do
    --     local pos = v.pos
    --     local station = v.station
    --     if station == winner then
    --         local actNode = {id = DDZ.ACT_SHENGLI, pos = pos}
    --         table.insert(actList, actNode)
    --     else
    --         local actNode = {id = DDZ.ACT_SHIBAI, pos = pos}
    --         table.insert(actList, actNode)
    --     end
    -- end
    -- self:getPlayUi():onDoPlayerActor(actList)
end

function M:onReStartGame(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===onReStartGame play ui is null===")
        return
    end
    local retCode = info.ret_code
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("======on 16009 player back to game retCode %d========", retCode))

    if retCode ~= 0 then
        Game.DDZPlayCom:gameBack()
        return
    end
    self:getPlayUi():backToInit()
end

function M:onChangeDoubleInfo()
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===onChangeDoubleInfo play ui is null===")
        return
    end
    self:getPlayUi():onRefreshDiPaiDouble({})
end

function M:onChangePlayerInfo()
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===onChangePlayerInfo play ui is null===")
        return
    end
    self:getPlayUi():onPlayerInfoRefresh()
    self:getPlayUi():onPlayerNameRefresh()
end

function M:checkWangZhaPoke(svrCards)
    if #svrCards == 2 then
        if svrCards[1] > 160 and svrCards[2] > 160 then
            return true
        end
    end
    return false
end

function M:refreshMatchInfo(roomId)
    Game.DDZPlayDB:setRoomId(roomId)
    Game.DDZNetCom:req16014(roomId)
end

function M:refreshMatchTurnInfo(roomId)
    Game.DDZNetCom:req16019(roomId)
end

function M:gameBack()
    local function pushCmd()
        if Game.recommendCom:isByQuick() then
            Game.recommendCom:setByQuick(false)
            return
        end
        local roomId = Game.DDZPlayDB:getRoomId()
        local roomType = RoomConfig.type(roomId)

        if roomType == 1 then
            Game.activityCom:goFunc(501)

        elseif roomType == 2 then
            Game.activityCom:goFunc(501)
        elseif roomType == 11 then --不洗牌
            Game.activityCom:goFunc(501)

        elseif roomType == 4 or roomType == 5 then
            Game.activityCom:goFunc(501)
        elseif roomType == 12 then --清空奖池数据
            Game.redJackpotDB:clearAllData()
        end
    end

    Game.DDZPlayCom:playerLeave(function()
        if self:getPlayUi() and self:getPlayUi().destroy then
            self:getPlayUi():destroy()
        end
        Game:openGameWithIdx(SCENCE_ID.PLATEFORM, pushCmd)
    end)
end

function M:goToMainSecene()
    if self:getPlayUi() and self:getPlayUi().destroy then
        self:getPlayUi():destroy()
    end
    Game:openGameWithIdx(SCENCE_ID.PLATEFORM, pushCmd)
end

function M:startSendPokes(show_poke)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===startSendPokes play ui is null===")
        return
    end

    self:getPlayUi():initPokeView(true)
    self:getPlayUi():startGetPokeAction(show_poke)

    if show_poke then
        local pokeData = Game.DDZPlayDB:getPokesData()
        self:getPlayUi():refreshPokePos(#pokeData, false, true)
        self:getPlayUi():refreshPokePos(#pokeData+1, false, true)
    end
    self:getPlayUi():showExitGamebutton(true)
    self:getPlayUi():onTuoguanRefresh()
    self:getPlayUi():clearFlyPanel()
end

function M:onMingPaiDataNew()
    if self._playUi and self._playUi.recreateMP then
        self._playUi:recreateMP()
    end
end

function M:errorHandle(retCode)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "====接收到服务端错误码: " .. tostring(retCode))
    if not cfg_util.getErrorTip(retCode) then
        return
    end
    if retCode == 16000006
        or retCode == 16000005
        or retCode == 16000009 then
        return
    end

    local step = Game.DDZPlayCom:getStep()
    if retCode == 16000012
        and step == DDZ_Step.POKE_END then
        return
    end

    if string.len(cfg_util.getErrorTip(retCode)) == 0 then
        return
    end

    if tonumber(retCode) == 16000002 or tonumber(retCode) == 16000003 then
        if tonumber(retCode) == 16000002 then
            local content = "金币不足以进入该场"
            Game:tipMsg(content)
            return
        else
            Game:tipError(retCode)
        end
        return
    end

    if tonumber(retCode) == 16000013 then
        local roomId = Game.DDZPlayDB:getRoomId()
        local magic_limit = 1000
        if roomId and roomId~=0 then
            magic_limit = RoomConfig.magic_limit(roomId)
        end
        Game:tipMsg(string.format(MsgConfig.text(retCode),magic_limit))
        return
    end

    if tonumber(retCode) == 11014001 then
        local str = string.format("您正在斗地主牌局中，点击确定继续牌局")
        local modalDialog = require_ex("ui.common.ModalDialog").new()
        local param = {
            callback1 = function()
                modalDialog:destroy()
            end,
            callback2 = function()
                Game.DDZPlayCom:enterRoom(0)
                modalDialog:destroy()
            end,
            content = str
        }
        if Game:getScenceIdx() == SCENCE_ID.DDZ then
            return
        end
        modalDialog:init(param):addToScene()
        Game.DDZPlayDB:setInPlaying(true)
        return
    end
    Game:tipMsg(cfg_util.getErrorTip(retCode), 2)
end

function M:onUseQpqHandle(info)
    Game.DDZPlayDB:setMyUseNote(1)

    local widgets = self:getPlayUi():getWidgets()
    local panJPQ = widgets.panJPQ
    self:getPlayUi():showJPQ(not panJPQ:isVisible())
    --self:getPlayUi():onChangeJPQNum()
end

function M:showJpqTips()
    Game.DDZNetCom:req16024()  --记牌器变为永久使用
    -- local num = Game.bagDB:getBagPropCount(nil, 0, 5)
    -- local id = 119
    -- local cost = ShareShopGoodsConfig.cost_list(id)[1]

    -- local str = string.format(stringCfgCom.content("jpq_tip"))
    -- if num <= 0 then
    --     Game:tipMsg("当前无记牌器可用！")
    --     return
    --     --local costName = GoodsConfig.name(cost[1])
    --     --local costNum = tostring(cost[2])
    --     --str = string.format("确认花费 %s%s 购买并使用记牌器？", costNum, costName)
    -- else
    --     Game.DDZNetCom:req16024()
    --     return
    -- end
    -- local modalDialog = require_ex("ui.common.ModalDialog").new()
    -- local param = {
    --     callback1 = function()
    --         modalDialog:destroy()
    --     end,
    --     callback2 = function()
    --         if num <= 0 then
    --             if Game.storeCom:onBuyGoodTips(id, cost) then
    --                 Game.DDZNetCom:req16024()
    --             end
    --         else
    --             Game.DDZNetCom:req16024()
    --         end
    --         modalDialog:destroy()
    --     end,
    --     content = str
    -- }
    -- modalDialog:init(param):addToScene()
end

function M:showGameTask(info, is_16022)
    if not self:getPlayUi() then
        return
    end
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===showGameTask===")
    Log(LOG.TAG.DDZ, LOG.LV.INFO, info)
    self:getPlayUi():showGameTask(info, is_16022)
end

function M:finishGameTask(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===finishGameTask play ui is null===")
        return
    end
    self:getPlayUi():onDDZ16023(info)
end

function M:onGameBoxNum(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===onGameBoxNum play ui is null===")
        return
    end
    self:getPlayUi():onDDZ16026(info)
end

function M:onGetMatchInfo(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===onGetMatchInfo play ui is null===")
        return
    end
    self:getPlayUi():onDDZ16019(info)
end

function M:onSystemSendCards(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===onSystemSendCards play ui is null===")
        return
    end
    local pos = info.pos
    local isMyPos = Game.DDZPlayDB:isMyPos(pos)
    if isMyPos then

        Game.DDZPlayDB:on16003(info)
        Game.DDZPlayCom:onGetPlayPokes(info.cards)
        Game.DDZPlayCom:startSendPokes(false)
        --Game.DDZPlayCom:setStep(DDZ_Step.DIAL) --取消叫地主前的明牌
    else
        if Game.DDZPlayDB:isEndLaiZi() then
            Game.DDZPlayDB:setPlayerPokes(pos, info.cards, false)
        else
            Game.DDZPlayDB:setPlayerPokes(pos, info.cards, true)
        end
    end
end

function M:onPlayerChooseState(info)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===onPlayerChooseState play ui is null===")
        return
    end
    -- 明牌
    if info.state == 5 then
        Game.DDZPlayDB:setMP(info.state_pos, info.state_type)
        Game.DDZPlayDB:setMingPai(info.state_pos, info.state_type)

        if Game.DDZPlayDB:isEndLaiZi() then
            Game.DDZPlayDB:setPlayerPokes(info.state_pos, info.cards, false)
        else
            Game.DDZPlayDB:setPlayerPokes(info.state_pos, info.cards, true)
        end
    -- 加倍
    elseif info.state == 3 then
        Game.DDZPlayDB:setPlayerDoubles(info.state_pos)
    end
    self:getPlayUi():onDDZ16005(info)
end

function M:onGetTableDiPai(info)
    print("onGetTableDiPai~~~~~~~~~~~~~~~~~~~~~~~~~")
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===onGetTableDiPai play ui is null===")
        return
    end
    Game.DDZPlayCom:getDDZEffc():effctDZBeauty(info.landlord_pos)

    if Game.DDZPlayDB:getIsLaiZiRoom() then
        Game.DDZPlayCom:onGetLaiZiPokes(info.laizi_cards[1])
    end
    local diPokes = info.table_cards
    local lzPokes = info.laizi_cards
    local landlordPos = info.landlord_pos
    Game.DDZPlayDB:onDizhuPosChange(landlordPos)
    Game.DDZPlayDB:setDiPai(diPokes, lzPokes)

    -- local bgDelay = cc.DelayTime:create(1.5)
    -- local bgCallback = cc.CallFunc:create(function ()
    --     Game.DDZPlayCom:onChangePlayerDiPai(true)
    -- end)
    -- local seq = cc.Sequence:create(bgDelay, bgCallback)
    -- self:getPlayUi():runAction(seq)
    Game.DDZPlayCom:onChangePlayerDiPai(true)

    if Game.DDZPlayDB:getIsLaiZiRoom() then
        Game.DDZPlayDB:onPokeDataChange(1, diPokes, landlordPos, true)
    else
        Game.DDZPlayDB:onPokeDataChange(1, diPokes, landlordPos)
    end
    Game.DDZPlayCom:onPokeNumChange()
    Game.DDZPlayCom:setJiPaiQiBunttonVisible(false)
    Game.DDZPlayCom:onChangeJPQUI()
end

function M:onChangeJPQUI()
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===onChangeJPQUI play ui is null===")
        return
    end
    local playUi = self:getPlayUi()
    playUi:refreshJPQ()
end

function M:onChangePokerInfo(data)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===onChangePokerInfo play ui is null===")
        return
    end
    local playUi = self:getPlayUi()
    if data.delay then
        local delay = cc.DelayTime:create(data.delay)
        local callback = cc.CallFunc:create(function()
            playUi:onPokerInfoRefresh(data)
        end)
        local seq = cc.Sequence:create(delay, callback)
        playUi:runAction(seq)
    else
        playUi:onPokerInfoRefresh(data)
    end
end

function M:onChangePlayerDiPai(is16011)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===onChangePlayerDiPai play ui is null===")
        return
    end
    local playUi = self:getPlayUi()
    if is16011 then
        playUi:onRefreshDiPai({is16011 = true})
    else
        playUi:onRefreshDiPai({})
    end
end

function M:changeRules()
    local isLaiZi = Game.DDZPlayDB:getIsLaiZiRoom()
    if isLaiZi == true then
        self._ddzRules = require_ex("games.ddz.models.DDZRulesLaiZi"):new()
    else
        self._ddzRules = require_ex("games.ddz.models.DDZRules"):new()
    end
end

--@ state : 牌局状态(2:抢地主，3:明牌/加倍)
--@ playPos : 玩家座位
--@ value : 1 为设置， 0 为不设置
function M:playerSetState(state, playPos, value)
    Game.DDZNetCom:req16005(state, playPos, value)
end

function M:getSuperDoubleCostNum()
    local id = 201
    local cost = ShareShopGoodsConfig.cost_list(id)[1]
    local costNum = tostring(cost[2])
    return costNum
end

function M:playerSuperDouble(svrPos)
    local num = Game.bagDB:getBagPropCount(nil, 0, 6)
    if num <= 0 then
        if RechargeConfig[321] then
            Game.rechargeCom:showSelectPay(RechargeConfig[321],function()
                Game.DDZPlayCom:playerSetState(3, svrPos, 2)
            end)
        else
            print("playerSuperDouble error,not have RechargeConfig[321")
        end
    else
        Game.DDZPlayCom:playerSetState(3, svrPos, 2)
    end
end

function M:playerTouchTuoguan()
    local nowState = Game.DDZPlayDB:getTuoguanState()
    if nowState == 0 then
        nowState = 1
    else
        nowState = 0
    end
    if self:getPlayUi() then
        self:getPlayUi():setTuoguanUsing(nowState == 1)
    end
    Game.DDZNetCom:req16012(nowState)
end

function M:playerReStart(isMP, is_higher)
    local uid = Game.playerDB:getPlayerUid()
    local mingpai = isMP and 1 or 0

    local curCoin = Game.playerDB:getPlayerCoin()
    local curRoomID = Game.DDZPlayDB:getRoomId()
    local nexRoomID = (curRoomID+1)

    local limitMax = Game.DDZPlayDB:getDDZLimitMax(curRoomID)
    if not isMP and limitMax ~= 0 and curCoin >= limitMax then
        self:playerLeave(function() self:fastEnterRoom(true, false, true) end)

    elseif not isMP and is_higher and RoomConfig[nexRoomID] then
        self:playerLeave(function() self:enterRoom(nexRoomID, false, true) end)

    elseif curCoin >= Game.DDZPlayDB:getDDZStartMin(curRoomID) then
        Game.DDZNetCom:req16009(uid, mingpai)
    else
        self:playerLeave(function() self:fastEnterRoom(false, true, false) end)
    end
end

function M:playerLeave(callback)
    local uid = Game.playerDB:getPlayerUid()
    Game.DDZNetCom:req16010(uid, callback)
end

function M:setStep(step)
    self._step = step
    if step == DDZ_Step.DIAL then
        local viewPos = 1
        local svrPos = Game.DDZPlayDB:getMyPos()

        if not Game.DDZPlayDB:getMingPai(svrPos) then
            self:getPlayUi():showMingpaiOper(svrPos, viewPos, 3)
        end
    end
end

function M:getStep()
    return self._step
end

function M:turnToPlayPoke()
    self._ddzRules:turnToMe()
end

function M:rebackOriPoke()
    if Game.DDZPlayDB:getIsLaiZiRoom() then
        self._ddzRules:rebackToFind(false)
    else
        self._ddzRules:rebackToFind(true)
    end
end

function M:onExitPoke()
    self:setPlayUi(nil)
    self:removeDDZNetEvent()
    Game.DDZPlayDB:clearOldData()
end

function M:onStartGetPoke()
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===onStartGetPoke begin fa pai===")
end

function M:onEndGetPoke()
    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===onEndGetPoke end fa pai===")

    self:onChangeJPQUI()
end

function M:doUnSelectAllPokes()
    local pokeData = Game.DDZPlayDB:getPokesData()
    if pokeData == nil then
        return
    end
    local select_pokes = Game.DDZPlayDB:getSelectedPoke()
    for k,data in pairs(pokeData) do
        self:onPokeUnSelected(k)
    end
    Game.DDZPlayDB:setSelectedPoke({})
end

function M:doUnSelectSelectPokes()
    local select_pokes = Game.DDZPlayDB:getSelectedPoke()
    for k,data in pairs(select_pokes or {}) do
        self:onPokeUnSelected(data)
    end
    Game.DDZPlayDB:setSelectedPoke({})
end

function M:doSelectAllPokes()
    local selTable = {}
    local pokeData = Game.DDZPlayDB:getPokesData()
    for k,data in pairs(pokeData) do
        self:onPokeSelected(k)
        table.insert(selTable, k)
    end
    Game.DDZPlayDB:setSelectedPoke(selTable)
end

--自己不出
function M:passPoke(yaobuqi)
    self:doUnSelectAllPokes()
    local toSvrPokes = {}

    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("=======passPoke========="))
    -- local playPos = Game.DDZPlayDB:getSvrPosWithViewPos(1)
    -- local deskPNode = self._playUi:getDeskNode(playPos)
    -- deskPNode:removeAllChildren()
    for i=1,3 do
        local deskPoke = self._playUi:getDeskPoke(i)
        deskPoke:removeChildByTag(DDZ.DESK_TIPS_TAG)
    end
    local deskPoke = self._playUi:getDeskPoke(1)
    -- 屏蔽延迟，优化卡顿 add by xuchenwei
    -- local putTime = SystemConfig.value("ddz_putpoke_time")
    -- local delay = cc.DelayTime:create((putTime+0.2))
    -- local callback = cc.CallFunc:create(function ()
    -- if yaobuqi then
    --     -- self._playUi:addDeskTips(deskPoke, "ddz_yaobuqi", 1)
    --     self._playUi:addDeskTips(deskPoke, "ddz_bu_chu", 1)  --统一显示“不出”，避免显示“要不起”给玩家造成泄露手牌的疑惑 add by xcw
    -- else
    --     self._playUi:addDeskTips(deskPoke, "ddz_bu_chu", 1)
    -- end
    scheduler.performWithDelayGlobal(function()
        if self and self._playUi and self._playUi.addDeskTips then
            self._playUi:addDeskTips(deskPoke, "ddz_bu_chu", 1)
        end
    end,0.2)
    -- end)
    -- local seq = cc.Sequence:create(delay, callback)
    -- self._playUi:runAction(seq)
    Game.DDZNetCom:req16006({}, {})
    self._pokeAction = false
end

function M:canQuickGo()
    local isClassic = Game.DDZPlayDB:getIsClassicRoom()
    local isWithoutWashRoom = Game.DDZPlayDB:getIsWithoutWashRoom()
    if isClassic or isWithoutWashRoom then
        local myLastGoPokeType = Game.DDZPlayDB:getLastMyGoPokeType()
        if myLastGoPokeType == PaiXing.CARD_TYPE_WANG_ZHA then
            local pokeData = Game.DDZPlayDB:getPokesData()
            local canGoAll = self._ddzRules:checkCanQuickGo(pokeData)
            if canGoAll then
                return true
            end
        end
    end
    return false
end

function M:goPoke()
    -- print("自己出牌")
    -- print(debug.traceback())
    local step = Game.DDZPlayCom:getStep()
    if step == DDZ_Step.POKE_END then
        return
    end
    local pokeData = Game.DDZPlayDB:getPokesData()
    local selPokes = Game.DDZPlayDB:getSelectedPoke()
    if not pokeData or not selPokes then return end  --容错 add by xcw

    local isMatchRoom = Game.DDZPlayDB:getIsMatchRoom()
    if isMatchRoom == true then
        local isTuoGuan = Game.DDZPlayDB:isTuoguan()
        local isFollowPoke = Game.DDZPlayDB:isFollowPoke()
        local isAlarm = Game.DDZPlayDB:isAlarmStatus()

        if isTuoGuan == true and isFollowPoke == true and isAlarm == false then
            if #selPokes < #pokeData then
                self:passPoke()
                return
            end
        end
    end

    local toSvrPokes = {}
    for k,v in pairs(selPokes) do
        table.insert(toSvrPokes, pokeData[v].svrNum)
    end

    local laiZiChange = {}
    if Game.DDZPlayDB:getIsLaiZiRoom() then
        local changes = self._ddzRules:getLaiZiChange()
        for k,v in pairs(changes) do
            local oriCard = v[1]
            local changeCard = v[2]
            table.insert(laiZiChange, {oriCard, changeCard})
        end
    end
    local sendTab = {#toSvrPokes, toSvrPokes, #laiZiChange, laiZiChange}
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("=======goPoke cur card num is: %d=========", #pokeData))
    Log(LOG.TAG.DDZ, LOG.LV.INFO, sendTab)
    --self:onPlayCardsAni(function()
        -- local info = {}
        -- info.pos = Game.DDZPlayDB:getSvrPosWithViewPos(1)
        -- info.laizi = laiZiChange
        -- info.cards = toSvrPokes
        -- Game.DDZPlayCom:getPlayUi():onDDZ16006(info)
        -- Game.DDZPlayDB:onPokeDataChange(0, toSvrPokes, info.pos)
        --注释上面的原因: 为了避免前后端出牌统一  先提交出牌请求 等服务器反馈了再演示出牌
        Game.DDZNetCom:req16006(toSvrPokes, laiZiChange)
    --end)
    self._pokeAction = true
end

function M:autoSelectPoke()
    self:doUnSelectAllPokes()
    self._ddzRules:autoSelectPoke()
    if self:getPlayUi() then
        self:getPlayUi():checkCanGoPoke()
    end
end

--@仅用于检测是否可以按提示出牌
function M:testAutoSelectPoke()
    if Game.DDZUtil:checkHaveDaXiaoWang() then
        return true
    end

    --检测牌型是否为非炸弹，则有炸弹可出牌
    local nowRoundState = Game.DDZPlayDB:getRoundState()
    if nowRoundState == 1 then
        if self._ddzRules.checkCanGoWithRoundPoke then
            if self._ddzRules:checkCanGoWithRoundPoke() then
                return true
            end
        end
    end

    local nowSelPoke = Game.DDZPlayDB:getSelectedPoke()
    self:doUnSelectAllPokes()
    local bigPoke = self._ddzRules:autoSelectPoke()
    local isCanGo = self:getPlayUi():checkCanGoPoke()
    self:doUnSelectAllPokes()

    if #nowSelPoke > 0 and bigPoke then
        Game.DDZPlayDB:setSelectedPoke(nowSelPoke)
        for k,v in pairs(nowSelPoke) do
            self:onPokeSelected(v)
        end
    end
    self:rebackOriPoke()
    return isCanGo
end

--@仅用于出牌选择部分牌后智能提示其他牌
function M:autoSelectOtherPoke()
    local isFollow = Game.DDZPlayDB:isFollowPoke()
    if isFollow ~= true then
        return
    end

    local isMyTurn = Game.DDZPlayDB:getMyTurn()
    if isMyTurn == false then
        return
    end
    local oldSelPoke = Game.DDZPlayDB:getSelectedPoke()
    if oldSelPoke and #oldSelPoke == 0 then
        return false
    end

    self:doUnSelectAllPokes()
    local exist = true
    local bigPoke = self._ddzRules:autoSelectPoke()
    local count = 0
    while bigPoke == true do
        exist = true
        local nowSelPoke = Game.DDZPlayDB:getSelectedPoke()
        for k,v in pairs(oldSelPoke) do
            local isExist = table.isExist(nowSelPoke, v)
            if isExist == false then
                exist = false
            end
        end
        if exist == true then
            break
        end
        self:doUnSelectAllPokes()
        bigPoke = self._ddzRules:autoSelectPoke()
        count = count + 1
        if count >= 21 then
            break
        end
    end


    if exist == false then
        if #oldSelPoke > 0 then
            self:doUnSelectAllPokes()
            Game.DDZPlayDB:setSelectedPoke(oldSelPoke)
            for k,v in pairs(oldSelPoke) do
                self:onPokeSelected(v)
            end
        end
    end

    --local isCanGo = self:getPlayUi():checkCanGoPoke()
    self:rebackOriPoke()
    return isCanGo
end

-- 自己出牌智能选中
function M:goPokeAutoSelectPoke()
    local isFollow = Game.DDZPlayDB:isFollowPoke()
    if isFollow == true then
        return false
    end
    local isMyTurn = Game.DDZPlayDB:getMyTurn()
    if isMyTurn == false then
        return false
    end
    local pokesNum = Game.DDZPlayDB:getNowPokeNum()
    local selectedPokes = Game.DDZPlayDB:getSelectedPokesData()
    if not selectedPokes or #selectedPokes < 3 or pokesNum == #selectedPokes then
        return false
    end
    local pokes = self._ddzRules:autoFulfillSelectPoke(selectedPokes)
    if pokes then
        return true
    end
    return false
end

function M:selectedPokeJuge(selectedPokes)
    local retPokes = self._ddzRules:selectedPokeJuge(selectedPokes)
    return retPokes
end

function M:selectedPokeJuge_chupai(selectedPokes)
    local retPokes = nil
    if Game.DDZPlayDB:getIsLaiZiRoom() then
        retPokes = self._ddzRules:selectedPokeJuge_chuPai(selectedPokes)
    else
        retPokes = self._ddzRules:selectedPokeJuge(selectedPokes)
    end
    return retPokes
end

function M:checkSelectedPoke()
    local selectedPokes = Game.DDZPlayDB:getSelectedPokesData()
    local pocksNum = #selectedPokes

    self._ddzRules:clearCheckType()
    local firstCheck = false

    if pocksNum == 1 then
        firstCheck = true
    end

    local checkTable = {}
    local getOkPokes = nil
    getOkPokes = self:selectedPokeJuge_chupai(selectedPokes)
    table.insert(checkTable, getOkPokes)

    if #checkTable > 0 then
        if #checkTable == 1 then
            local okPokes = checkTable[1]
            if #okPokes == pocksNum then
                firstCheck = true
            else
                firstCheck = false
            end
        else
            Log(LOG.TAG.DDZ, LOG.LV.ERROR, "error !! more result!!")
            return false
        end
    else
        firstCheck = false
    end

    if firstCheck == true then
        local selPokeData = nil
        local secondCheck = false
        if Game.DDZPlayDB:getIsLaiZiRoom() then
            local changes = self._ddzRules:getLaiZiChange()
            local nums = self._ddzRules:converLZToOri(selectedPokes, changes)
            selPokeData = Game.DDZPlayCom:converSvrPokeToClient(nums)
        else
            selPokeData = selectedPokes
        end
        local pokeSelType = self._ddzRules:getPokeType(selPokeData)
        if pokeSelType == nil then
            Log(LOG.TAG.DDZ, LOG.LV.INFO, "pokeSelType is nil")
            return false
        end

        local num, pokeNum = self._ddzRules:getKeyLastNum(selPokeData, pokeSelType)
        local checkRet = self._ddzRules:checkToRoundTypeNum(pokeSelType, num)
        if checkRet == true then
            secondCheck = true
        else
            Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("===num is:%s, pokeNum is:%s, pokeSelType is:%s", tostring(num), tostring(pokeNum), tostring(pokeSelType)))
            -- Log(LOG.TAG.DDZ, LOG.LV.INFO, selPokeData)
        end
        return secondCheck
    else
        -- Log(LOG.TAG.DDZ, LOG.LV.INFO, "firstCheck is false")
        -- Log(LOG.TAG.DDZ, LOG.LV.INFO, selectedPokes)
        return false
    end
end

function M:converSvrPokeToClient(allPokes, changes, change)
    local mapLaiZi = {}
    if changes ~= nil then
        mapLaiZi = Game.DDZUtil:buildLZMap(changes)
    end
    local laiziNum = Game.DDZPlayDB:getLaiZiNum()
    local retClientData = {}
    for k,v in pairs(allPokes) do
        local svrPokeNum = v
        local lowNum = svrPokeNum%10
        local highNum = math.floor(svrPokeNum/10)
        local oneData = {}
        oneData.svrNum = svrPokeNum
        oneData.type = lowNum
        oneData.num = highNum
        oneData.sortnum = highNum
        oneData.lie = false
        if laiziNum == highNum and not change then
            local lzReal = mapLaiZi[svrPokeNum]
            if lzReal ~= nil then
                oneData.num = math.floor(lzReal/10)
                oneData.sortnum = oneData.num
            else
                oneData.sortnum = 99
            end
            oneData.lie = true
        end
        table.insert(retClientData, oneData)
    end
    self:sortClientData(retClientData)
    return retClientData
end

function M:sortClientData(clientData)
    local tempData = table.newclone(clientData)
    table.sort(clientData, function(a, b)
        local retValue = false
        local anum = a.sortnum
        local bnum = b.sortnum
        if anum > bnum then
            retValue = true
        elseif anum == bnum then
            if a.type > b.type then
                retValue = true
            end
        end
        return retValue
    end)
    for i,v in ipairs(clientData) do
        v.index = i
        for key,value in ipairs(tempData) do
            --匹配原始位置 双循环之后再优化
            if (value.sortnum == v.sortnum) and (value.type == v.type) then
                v.originIdx = key
            end
        end
    end
end

function M:sortClientDataJustNum(clientData)
    table.sort(clientData, function(a, b)
        local retValue = false
        local anum = a.num
        local bnum = b.num
        if anum > bnum then
            retValue = true
        elseif anum == bnum then
            if a.type > b.type then
                retValue = true
            end
        end
        return retValue
    end)
    for i,v in ipairs(clientData) do
        v.index = i
    end
end

-- 场次界面快速开始
function M:onRoomFastStart(room_type)
    if Game.DDZPlayDB and Game.DDZPlayDB:isInPlaying() then
        local str = string.format("您正在斗地主牌局中，点击确定继续牌局")
        local modalDialog = require_ex("ui.common.ModalDialog").new()
        local param = {
            callback1 = function()
                modalDialog:destroy()
            end,
            callback2 = function()
                Game.DDZPlayCom:enterRoom(0)
                modalDialog:destroy()
            end,
            content = str
        }
        modalDialog:init(param):addToScene()
    else
        local playerRoomId = Game.playerDB:getRoomId()
        if playerRoomId ~= 0 then --表示有重连，直接返回不做任何操作
            return
        end
        local roomId = room_type*100 + 1
        local player_coin = Game.playerDB:getPlayerCoin()
        local needCoin = Game.DDZPlayDB:getDDZLimitMin(roomId)
        local bank_coin = Game.safeboxDB:getBankCoin()

        if (player_coin + bank_coin) < needCoin and not IS_IOS_TS then
            local stage = roomId % 100
            if stage == 1 and player_coin < 1000 and Game.rechargeDB:canGetSystemAward() then
                require_ex("ui.common.SystemAssistUI").new():addToScene(UIZorder.Dialog)
            else
                self:openDDZRecharge(roomId)
            end
            return
        end

        if player_coin < needCoin then --此时已满足bank_coin>0
            -- local str = string.format("当前还缺%d金币可以进入游戏，请从银行里取出对应金币",needCoin-player_coin)
            -- if IS_IOS_TS then -- ios提审不能出现保险箱字样
            --     str = string.format("您还缺%d金币可进入房间",needCoin-player_coin)
            -- end
            -- Game:tipMsg(str,2,nil,nil,nil,2)
            if not IS_IOS_TS then
                local roomId = room_type*100 + 1
                local minCoin = Game.DDZPlayDB:getDDZLimitMin(roomId)
                local bankCoin = Game.safeboxDB:getBankCoin()
                local modalDialog = require_ex("ui.common.ModalDialog").new()
                local param = {
                    content = string.format("金币不足%d，您的银行存有%d金币，是否前往银行？", minCoin, bankCoin),
                    callback1 = function()
                        if modalDialog and modalDialog.destroy then
                            modalDialog:destroy()
                        end    
                    end,
                    callback2 = function()
                        if modalDialog and modalDialog.destroy then
                            modalDialog:destroy()
                        end
                        Game.safeboxCom:openSafeboxUI() 
                    end,
                }
                modalDialog:init(param):addToScene()
                modalDialog:setButtonText(1, "返回大厅")
                modalDialog:setButtonText(2, "立即前往")
            end
            return
        end

        Game.DDZPlayDB:setRoomType(room_type)
        Game.DDZPlayCom:fastEnterRoom(false, false, false)
        Game.recommendCom:handleHud(Game.DDZPlayDB:getRoomId())
    end
end

function M:setJiPaiQiBunttonVisible(is_begin)
    if not self:getPlayUi() then
        Log(LOG.TAG.DDZ, LOG.LV.WARN, "===setJiPaiQiBunttonVisible play ui is null===")
        return
    end
    self:getPlayUi():showJiPaiQiBtnState(is_begin)
end

function M:setTuoGuanMaskPoke(is_mask)
    if self:getPlayUi() then
        self:getPlayUi():setPokeMask(is_mask)
    end
end

function M:isShowSuperDouble()
    local roomid = Game.DDZPlayDB:getRoomId()
    local superLimit = RoomConfig[roomid].super_limie

    local mySuperTime = Game.playerDB:getSuperTime()
    local nowCoin = Game.playerDB:getPlayerCoin()
    local num = Game.bagDB:getBagPropCount(nil, 0, 6)

    if num <= 0 then
        return false
    end
    -- return (nowCoin >= superLimit)
    return false
end

function M:getTypeAndNumByIdx(idx)
    if idx == 1 then
        return 5, BIG_JOKER
    elseif idx == 2 then
        return 5, SMALL_JOKER
    else
        local tmp = idx - 2
        local type = math.ceil(tmp/13)
        local seqId = math.floor(tmp%13)

        local realSeq = seqId + 2
        if realSeq == 1 then
            return type, ACE
        elseif realSeq == 2 then
            return type, TWO
        else
            return type, realSeq
        end
    end
end

function M:onPokeNumChange()
    if self:getPlayUi() then
        self:getPlayUi():onPokeNumChange()
    end
end

function M:getPokeType(poke)
    local type, beginNum = self._ddzRules:getPokeType(poke)
    return type, beginNum
end

-- 自动适配合适的房间
function M:autoMatchRoom(coin , roomType)
    local roomIds = RoomConfig.getIds()
    local roomId = 1

    table.sort(roomIds , function(v1 , v2)
        return v1 > v2
    end)

    for _ , id in pairs(roomIds) do
        if tonumber(RoomConfig.type(id)) == roomType then
            if coin >= Game.DDZPlayDB:getDDZLimitMin(id) then
                roomId = id
                return roomId
            end
        end
    end
end

function M:onPokeSelected(index)
    local poke = Game.DDZPlayDB:getOnePokeWithIndex(index)
    if poke == nil then
        local alls = Game.DDZPlayDB:getPokesData()

        Log(LOG.TAG.DDZ, LOG.LV.INFO, "error index  "..index)
        Log(LOG.TAG.DDZ, LOG.LV.INFO, alls)
        return
    end
    local pokeView = poke.pokeView
    if not pokeView then
        local alls = Game.DDZPlayDB:getPokesData()

        Log(LOG.TAG.DDZ, LOG.LV.INFO, "pokeView error index  "..index)
        Log(LOG.TAG.DDZ, LOG.LV.INFO, alls)
        return
    end
    poke.selected = true
    pokeView:setColor(cc.c3b(255, 255, 255))
    -- pokeView:setPositionY(pokeOriPos+30)

    pokeView:stopAllActions()
    local x = pokeView:getPositionX()
    local moveTo = cc.MoveTo:create(0.04, cc.p(x, (pokeOriPos+20)))
    pokeView:runAction(moveTo)

    if self:getPlayUi() then
        self:getPlayUi():checkCanGoPoke()
    end
end

function M:onPokeUnSelected(index)
    local poke = Game.DDZPlayDB:getOnePokeWithIndex(index)
    local pokeView = poke.pokeView
    if not pokeView then
        return
    end
    poke.selected = false
    pokeView:setColor(cc.c3b(255, 255, 255))
    -- pokeView:setPositionY(pokeOriPos)

    pokeView:stopAllActions()
    local x = pokeView:getPositionX()
    local moveTo = cc.MoveTo:create(0.04, cc.p(x, pokeOriPos))
    pokeView:runAction(moveTo)

    if self:getPlayUi() then
        self:getPlayUi():checkCanGoPoke()
    end
end

function M:onCheckSelectPokes(pos, touchType)
    self._selectedPokeIdx = {}
    local nowPos = pos
    self._beginPos = self._beginPos or nowPos

    local maxX = compareMax(nowPos.x, self._beginPos.x)
    local minX = compareMin(nowPos.x, self._beginPos.x)

    local pokeData = Game.DDZPlayDB:getPokesData()
    for k,data in pairs(pokeData) do
        local v = data.pokeView
        if v ~= nil then
            local rect = v:getBoundingBox()

            local pokeRectMinX = rect.x
            local pokeRectMaxX = rect.x + Game.DDZPlayDB:getNowPokeSpan()
            if (pokeRectMinX >= minX and pokeRectMinX <= maxX)
                or (pokeRectMaxX >= minX and pokeRectMaxX <= maxX) then
                self._selectedPokeIdx[k] = true
            end

            if k ~= #pokeData then
                rect.width = Game.DDZPlayDB:getNowPokeSpan()
            end

            if cc.rectContainsPoint(rect, pos) then
                self._selectedPokeIdx[k] = true
            end

            if self._selectedPokeIdx[k] == nil then
                local nowColor = v:getColor()
                if nowColor.r ~= 255 and nowColor.g ~= 255 and nowColor.b ~= 255 then
                    Game.DDZPlayCom:getDDZEffc():playSelPokeEffect()
                end
                v:setColor(cc.c3b(255, 255, 255))
            else
                local nowColor = v:getColor()
                if nowColor.r == 255 and nowColor.g == 255 and nowColor.b == 255 then
                    -- 连续选牌的音效调整为只播放一次 add by xcw
                    if touchType ~= ccui.TouchEventType.moved then
                        Game.DDZPlayCom:getDDZEffc():playSelPokeEffect()
                    end
                end
                v:setColor(cc.c3b(159, 168, 176))
            end
        else
            Log(LOG.TAG.DDZ, LOG.LV.ERROR, "===pokeview is nil: ")
            Log(LOG.TAG.DDZ, LOG.LV.ERROR, data)
        end
    end
end

function M:checkPokeTouch(pos, touchType)
    local step = Game.DDZPlayCom:getStep()
    if step ~= DDZ_Step.DA_PAI then
        return
    end
    self._inTouchMode = true
    if touchType == ccui.TouchEventType.began then
        self._beginPos = pos
    end

    self:onCheckSelectPokes(pos, touchType)

    if touchType == ccui.TouchEventType.moved then
    end

    local pokeData = Game.DDZPlayDB:getPokesData()
    if touchType == ccui.TouchEventType.ended
        or touchType == ccui.TouchEventType.canceled then
        self._moveTouchLock = {}
        self._inTouchMode = false

        local select_poke_num = 0
        local noNeedAutoSelectOther = false
        for k,v in pairs(self._selectedPokeIdx) do
            if pokeData[k].selected == true then
                self:onPokeUnSelected(k)
                noNeedAutoSelectOther = true
            else
                select_poke_num = select_poke_num + 1
                self:onPokeSelected(k)
            end
        end

        local selectPoke = {}
        for k,data in pairs(pokeData) do
            if data.selected == true then
                table.insert(selectPoke, k)
            end
        end
        Game.DDZPlayDB:setSelectedPoke(selectPoke)
        local checkSel = Game.DDZPlayCom:checkSelectedPoke()
        if checkSel or Game.DDZPlayDB:getIsLaiZiRoom() then
            noNeedAutoSelectOther = true
        end
        -- if noNeedAutoSelectOther == false then
        --     local allCanGo = self:autoSelectOtherPoke()
        -- end
        -- if select_poke_num >= 2 then
        --     local isSucc = self:goPokeAutoSelectPoke()
        -- end
    end
end

function M:showDDZMatchDescUI(matchType, autoEnroll)
    self:openMatchWait(Game.DDZPlayDB:getRoomId())
end

function M:openMatchWait(roomId , view)
    self:reqEnrollMatch(roomId , function(info)
        self:onMatchReadyToStart(roomId)
        require_ex("games.ddz.views.DDZMatchWait").new(self , roomId , view , info):addToScene()
    end)
end

function M:backToMatchWait(roomId , callback)
    Game.DDZNetCom:req16030(roomId , function(info)
        self:onMatchReadyToStart(roomId)
        require_ex("games.ddz.views.DDZMatchWait").new(self , roomId , view , info):addToScene()
        if callback then
            callback()
        end
    end)
end

function M:enterToWaitView(roomId)
    self:onMatchReadyToStart(roomId)
    require_ex("games.ddz.views.DDZMatchWait").new(self , roomId , view):addToScene()
end

function M:showBackToMatchWaitConfirm(roomId)
    local content = string.format("%s即将开赛，是否前往赛场？" , RoomConfig.name(roomId))
    local modalDialog = require_ex("ui.common.ModalDialog").new(nil , {bValid = true})
    local param = {
        callback1 = function()
            -- 取消
            modalDialog:destroy()
        end,
        callback2 = function()
            -- 确认
            modalDialog:destroy()
            if Game:getScenceIdx() ~= SCENCE_ID.DDZ then
                self:enterToWaitView(roomId)
            end
        end,
        content = content
    }
    modalDialog:init(param):addToScene()
end

function M:showCancelSignConfirm(callback)
    local modalDialog = require_ex("ui.common.ModalDialog").new(nil , {bValid = true})
    local param = {
        callback1 = function()
            -- 取消
            modalDialog:destroy()
        end,
        callback2 = function()
            -- 确认
            modalDialog:destroy()
            if callback then
                callback()
            end
        end,
        content = "是否确认退出比赛？"
    }
    modalDialog:init(param):addToScene()
end

function M:cancelSign(roomId , callback)
    Game.DDZNetCom:req16017(roomId , callback)
end

function M:showDDZMatchUI(view)
    if not Game:funcIsOpen(GAME_OPEN_FUNC_CFG.MATCH , true) then
        return
    end
    self._ddzMatchUI = require_ex("games.ddz.views.DDZMatchSign").new(self)
    Game:addLayer(self._ddzMatchUI)
    return self._ddzMatchUI
end

function M:onCloseDDZMatchUI()
    self._ddzMatchUI = nil
end

function M:closeDDZMatchDescUI()
    if self._ddzMatchDescUi  then
        self._ddzMatchDescUi:onBackClicked()
    end
end

function M:setDDZMatchIsvisible(isvisibke)
    if self._ddzMatchUI  then
        self._ddzMatchUI:invisible(isvisibke)
    end
end

function M:reqRoomInfo()
    local id = Game.playerDB:getPlayerUid()
    if id == 0 then return end

    Game.DDZNetCom:req16027()
end

function M:setDDZMatchDescUIBarPercent(number,percent)
    if self._ddzMatchDescUi then
        self._ddzMatchDescUi:setLoadingBarPercent(number,percent)
    end
end

function M:showDDZMatchRewardUI(info)
    local ddzMatchRewardUI = require_ex("games.ddz.views.DDZMatchRewardUI"):new()
    ddzMatchRewardUI:init(info)
    Game:addLayer(ddzMatchRewardUI)
end

function M:reqEnrollMatch(roomId , callback)
    local roomType = RoomConfig.type(roomId)
    print("send : id "  , roomId)
    -- if roomType == 3 then
    --     Game.DDZNetCom:req16030(roomId , callback)
    -- else
    Game.DDZNetCom:req16015(roomId, callback)
    -- end
end

function M:isFit(coin , roomId)
    return coin >= Game.DDZPlayDB:getDDZLimitMin(roomId)
       and coin <= Game.DDZPlayDB:getDDZLimitMax(roomId)
end

function M:getFitRoom(coin, roomType)
    local ids = RoomConfig.getIds()
    local curIds = {}
    for __ , id in ipairs(ids) do
        if roomType == RoomConfig.type(id) then
            table.insert(curIds, id)
        end
    end

    table.sort(curIds, function(v1, v2)
        return v1 < v2
    end)

    local roomId = 0
    for __, id in ipairs(curIds) do
        if Game.DDZPlayDB:getDDZLimitMax(id) == 0 then
            if coin >= Game.DDZPlayDB:getDDZLimitMin(id) then
                roomId = id
            end
        elseif coin >= Game.DDZPlayDB:getDDZLimitMin(id) and coin<Game.DDZPlayDB:getDDZLimitMax(id) then
            roomId = id
        end
    end
    if roomId == 204 then
        return 203
    end
    return roomId
end

function M:isCanStart(coin, roomId)
    return coin >= Game.DDZPlayDB:getDDZLimitMin(roomId)
end

function M:isCanRestart(coin, roomId)
    return coin >= Game.DDZPlayDB:getDDZStartMin(roomId)
end

function M:ismatchTime(matchType)
    local currentTime = os.date("*t", TimeUtil:getCurTimeStamp())
    local starttime = 10000 + RoomConfig[matchType].game_time[1]
    local endtime = 10000 + RoomConfig[matchType].game_time[2]
    local startHours = tonumber(string.sub(starttime, 2, 3))
    local startMinute = tonumber(string.sub(starttime, 4, 5))
    local endHours = tonumber(string.sub(endtime, 2, 3))
    local endMinute = tonumber(string.sub(endtime, 4, 5))

    if startHours < endHours then
        if startHours < currentTime.hour and
            currentTime.hour < endHours then
            return true
        end
        if startHours == currentTime.hour and startMinute <= currentTime.min  then
            return true
        end
        if endHours == currentTime.hour and endMinute > currentTime.min  then
            return true
        end
    else
        if startHours < currentTime.hour or currentTime.hour < endHours then
            return true
        end
        if startHours == currentTime.hour and startMinute <= currentTime.min  then
            return true
        end
        if endHours == currentTime.hour and endMinute > currentTime.min  then
            return true
        end
    end
    return false
end

function M:openInforUi(svrPos, pos)
    if IS_IOS_TS then return end
    -- self:closeInforViews()

    -- self._InforUI = require_ex("games.ddz.views.InforUI"):new()
    -- Game:addLayer(self._InforUI)

    -- self._InforUI:openInforViews(svrPos, pos)
    -- self._InforUI:initInforViews(svrPos)
    -- self._InforUI:showWuJianSkill(svrPos)
    local info = Game.DDZPlayDB:getDDZPlayer(svrPos)
    if not info then return end  --容错
    local myPlayUid = Game.playerDB:getPlayerUid()
    require_ex("ui.role.infor_ui"):new(myPlayUid==info.uid,info):addToScene(UIZorder.Dialog)
end

function M:closeInforViews()
    if tolua.isnull(self._InforUI) then
        self._InforUI = nil
    end
    if self._InforUI ~= nil then
        self._InforUI:setVisible(false)
        self._InforUI:closeInforViews()
        self._InforUI = nil
    end
end

function M:openDDZJieSuanUI(info)
    self:closeDDZBeiShuUI()     --先关闭游戏时打开的倍数界面
    local rechargeView = Game.uiManager:getLayer("GiftRechargeUI")
    if rechargeView then
        rechargeView:destroy()
    end

    -- local jieSuanUI = require_ex("games.ddz.views.DDZResultUI"):new(info)
    local jieSuanUI = require_ex("games.ddz.views.Result_new").new(self , info)

    Game:addLayer(jieSuanUI, (UIZorder.PopWin))

    return jieSuanUI
end

function M:chongZhiUI()
    local uiLayer = Game.uiManager:getLayer("DDZResultUI")
    if uiLayer then uiLayer:onWait() end
end

function M:onDDZGoOn()
    local uiLayer = Game.uiManager:getLayer("DDZResultUI")
    if uiLayer then uiLayer:onGoOn() end
end

function M:onXuJu(is_higher)
    local uiLayer = Game.uiManager:getLayer("DDZResultUI")
    if uiLayer then uiLayer:onBtnXuJu(is_higher) end
end

function M:onDDZJieSuanTimeOut()
    local uiLayer = Game.uiManager:getLayer("DDZResultUI")
    if uiLayer then uiLayer:onTimeOut() end
end

function M:reSetDDZJieSuanUI()
    Game.misnCom:hideEnterNextRoom()
end

--使用透视卡
function M:reqDipaiCard(callback)
    local uid = Game.playerDB:getPlayerUid()
    netCom.send({uid},16031,function(pack)
        local info,cursor = netCom.parsePackByProtocol(pack,cursor,"s2c_poke_use_show")
        dump(info,"on16031")
        if info.ret_code == 0 then
            if callback then
                callback(info)
            end
        elseif info.ret_code == 13003001 then
            Game:tipMsg("透视卡数量不足")
        else
            Game:tipError(info.ret_code)
        end
    end)
end

--@ 打开倍数界面
function M:openDDZBeiShuUI()
    local doublesData = Game.DDZPlayDB:getDoublesInfo()

    if doublesData ~= nil then
        self._DDZBeiShuUI = require_ex("games.ddz.views.DDZBeiShuUI"):new()
        self._DDZBeiShuUI:initViews(doublesData)
        Game:addLayer(self._DDZBeiShuUI)
    end
end

function M:setDDZBeiShuUI(ui)
    self._DDZBeiShuUI = ui
end

--@ 关闭倍数界面
function M:closeDDZBeiShuUI()
    if self._DDZBeiShuUI ~= nil then
        self._DDZBeiShuUI:closeDDZBeiShuUI()
        self._DDZBeiShuUI = nil
    end
end

function M:onEvent(event_id, evnet_data)
    if event_id == DDZEvent.DDZ_NEW_GAME_EVENT then
        self:onNewGame(evnet_data)

    elseif event_id == DDZEvent.DDZ_ON_16014 then
        self:onDDZ16014(evnet_data)

    elseif event_id == DDZEvent.DDZ_ON_16016 then
        self:onDDZ16016(evnet_data)

    elseif event_id == DDZEvent.DDZ_ON_16021 then
        self:onDDZ16021(evnet_data)

    elseif event_id == DDZEvent.DDZ_TUOGUAN_UPDATE_EVENT then
        self:onUpdateTuanGuan(evnet_data)

    elseif event_id == DDZEvent.DDZ_PLAYER_REFRESH_EVENT then
        self:onPlayerUpdateEvent(evnet_data)

    elseif event_id == DDZEvent.DDZ_SHOW_NO_BIG_POKE_EVENT then
        self:onNoBigPokeEvent(evnet_data)

    elseif event_id == DDZEvent.DDZ_SELF_MP_EVENT then
        self:onPokeMPEvent(evnet_data)

    elseif event_id == DDZEvent.DDZ_MATCH_POINT_EVENT then
        self:onMatchPointEvent(evnet_data)

    elseif event_id == DDZEvent.DDZ_ON_ACTIVITY then
        self:onShowActivity(evnet_data)
    end
end

function M:onShowActivity(evnet_data)
    if not Game.activityDB:isOperateOpen(11, Game.DDZPlayDB:getRoomId()) then
        return
    end
    if self:getPlayUi() then
        local oper_data = table.newclone(Game.activityDB:getOperate(11))

        local sub_id = 11*100000+1
        local condition_list = OperatySubConfig.condition_list(sub_id) or {}
        local condition = condition_list[1] or {}
        local need = tostring(condition[2])

        oper_data.need = need
        self:getPlayUi():onTouchActPlay(oper_data)
    end
end

function M:onNewGame(evnet_data)
    local is_new_game = evnet_data[1]
    if self:getPlayUi() then
        self:getPlayUi():onNewGame(is_new_game)
    end
    local layer1 = Game.uiManager:getLayer("DDZBeiShuUI")
    if layer1 then layer1:destroy() end

    local layer2 = Game.uiManager:getLayer("DDZResultUI")
    if layer2 then layer2:destroy() end
end

function M:onDDZ16014(evnet_data)
    local layer1 = Game.uiManager:getLayer("DDZMatchSign")
    if layer1 then layer1:initContent(evnet_data.room_list) end

    local layer2 = Game.uiManager:getLayer("DDZResultUI")
    if layer2 then layer2:changeText(evnet_data) end
end

function M:onDDZ16016(evnet_data)
    local layer1 = Game.uiManager:getLayer("DDZMatchWait")
    if layer1 then layer1:on16016(evnet_data.number) end

    local layer2 = Game.uiManager:getLayer("DDZMatchDescUI")
    if layer2 then layer2:onEnrollNumChange(evnet_data.number) end
end

function M:onDDZ16021(evnet_data)
    if self:getDDZUIRefresh() then
        self:getDDZUIRefresh():on16021(evnet_data)
    end
end

function M:onUpdateTuanGuan(evnet_data)
    print("DDZPlayCom:onUpdateTuanGuan!!!")
    -- 先注掉，暂时没发现异常 by xuchenwei
    -- if self:getDDZUIRefresh() and evnet_data.refresh then
    --     self:getDDZUIRefresh():onPlayerInfoRefresh()
    -- end
    if self:getPlayUi() then
        self:getPlayUi():onTuoguanRefresh()
    end
end

function M:onPlayerUpdateEvent(evnet_data)
    if self:getPlayUi() then
        self:getPlayUi():onPlayerInfoRefresh()
    end
end

function M:onNoBigPokeEvent(evnet_data)
    if self:getPlayUi() then
        self:getPlayUi():showNoBigPoke(evnet_data.isShow)
    end
end

function M:onPokeMPEvent(evnet_data)
    if self:getPlayUi() then
        self:getPlayUi():refreshPokeMPIcon()
    end
end

function M:onMatchPointEvent(evnet_data)
    if self:getPlayUi() then
        --self:getPlayUi():refreshAllJiFen()
    end
end

function M:onLogoutRoom(event_data)
    if event_data.ret_code == 0 then
        Game.DDZPlayDB:setInPlaying(false)
    end
end

------------------------英雄排位赛入口start--------------------
function M:openRankingMatch(preView, type)
    require_ex("games.ddz.views.RankingMatch").new(self, preView):addToScene()
end

function M:openSelectRoleView(preView, type)
    require_ex("games.ddz.views.SelectRole").new(self, preView, type):addToScene()
end

function M:reqRankingList()
end

function M:openMatchingView(preView, type, role_list)
    -- TODO 暂时进入英雄模式
    local room_id = 401
    if type == 2 then
        room_id = 501
    end
    local needCoin = Game.DDZPlayDB:getDDZLimitMin(room_id)
    local maxCoin = Game.DDZPlayDB:getDDZLimitMax(room_id)
    local coin = Game.playerDB:getPlayerCoin()
    if coin >= maxCoin then
        if type == 1 then
            room_id = 402
        else
            room_id = 502
        end
        needCoin = Game.DDZPlayDB:getDDZLimitMin(room_id)
        maxCoin = Game.DDZPlayDB:getDDZLimitMax(room_id)
    end
    if coin > maxCoin and maxCoin ~= 0 then
        Game:tipError(16000003)
        return
    elseif coin < needCoin then
        Game:tipMsg("金币不足以进入该场")
        return
    end

    self:onHeroRankMatchReadyToStart(room_id, role_list)
    require_ex("games.ddz.views.MatchingView").new(self , preView , type, role_list):addToScene()
end

function M:openDDZRecharge(roomId,closeCb,rechargeCb)
    -- 需要先向服务器请求商城列表
    Game.rechargeCom:getSubGameRecharge(roomId, function ( _list )
        _list.roomId = roomId
        local subRechargeView = require_ex("ui.recharge.SubRechargeView").new(_list):addToScene(UIZorder.Dialog)
        if closeCb then
            subRechargeView:setCloseCallback(closeCb)
        end
        if rechargeCb then
            subRechargeView:setRechargeCb(rechargeCb)
        end
    end)
end
------------------------英雄排位赛入口end----------------------

---------------------------------------------斗地主结算补偿--------------------------------------


function M:onDDZSettle()
    local roomId = Game.DDZPlayDB:getRoomId()
    local minCoin = Game.DDZPlayDB:getDDZLimitMin(roomId)
    local myCoin = Game.playerDB:getPlayerCoin()
    local needCoin = Game.DDZPlayDB:getDDZLimitMin(roomId)
    local bankCoin = Game.safeboxDB:getBankCoin()
    local maxCoin = Game.DDZPlayDB:getDDZLimitMax(roomId)
    local stage = roomId % 100
    if (myCoin+bankCoin) <= minCoin then    --跟保险柜的金币加起来还不到1000

        if IS_IOS_TS then-- IOS提审直接弹出商城
            Game.rechargeCom:openRechargeView("Coin")
            return
        end
        if stage == 1 then          --初级场检测破产补助
            if Game.rechargeDB:canGetSystemAward() then
                --打开破产补助界面
                local assistUI = self:openSystemAssistUI()
                assistUI:setCloseCallback(function()
                    Game.DDZPlayCom:playerLeave(function() Game.DDZPlayCom:gameBack() end)
                end)
                assistUI:setGetAssistCallback(function()
                    myCoin = Game.playerDB:getPlayerCoin()
                    if myCoin >= minCoin then
                        Game.DDZPlayCom:goOnReady()
                    else
                        Game.DDZPlayCom:playerLeave(function() Game.DDZPlayCom:gameBack() end)
                    end
                end)
                assistUI:setRechargeCb(function()
                    local playUI = Game.DDZPlayCom:getPlayUi()
                    if playUI then
                        playUI:refreshGold()
                    end
                    local playerCoin = Game.playerDB:getPlayerCoin()
                    local limitMax= Game.DDZPlayDB:getDDZLimitMax(roomId)
                    local limitMin = Game.DDZPlayDB:getDDZLimitMin(roomId)
                    if (playerCoin > limitMax) and (limitMax~=0) then
                        self:showLvUpRoomTips(function()
                            -- 升场玩，回调
                            local roomId = Game.DDZPlayCom:getMyFitRoom()
                            Game.DDZPlayCom:upgrade()
                        end)
                    end
                end)
            else --打开小商城界面
                Game.DDZPlayCom:openDDZRecharge(roomId,function()
                    Game.DDZPlayCom:playerLeave(function() Game.DDZPlayCom:gameBack() end)
                end)
            end
        else                        --其余弹小商城界面
            Game.DDZPlayCom:openDDZRecharge(roomId,function()
                Game.DDZPlayCom:playerLeave(function() Game.DDZPlayCom:gameBack() end)
            end)
        end
    elseif myCoin <= minCoin then       -- 保险柜有余额没取出
                
        if IS_IOS_TS then-- IOS提审直接弹出商城
            Game.rechargeCom:openRechargeView("Coin")
            return
        end
        local str = string.format("您还缺少%d金币进入游戏,请从银行取出相应金币进行游戏",minCoin-myCoin)
        if IS_IOS_TS then
            str = string.format("您还缺%d金币可进入房间",minCoin-myCoin)
        end
        Game.DDZPlayCom:playerLeave(
        function()
            Game:openGameWithIdx(SCENCE_ID.PLATEFORM)
            Game:tipMsg(str,1)
        end)
    elseif (myCoin>maxCoin) and (maxCoin~=0) then --升场
        self:showLvUpRoomTips(function()
            -- 升场玩，回调
            local roomId = self:getMyFitRoom()
            self:upgrade()
        end)
    else   --正常玩
        self:goOnReady()
    end
end

--[[
args :{
    cpsSucs : 补偿成功回调
    cpsFail : 补偿失败回调
    lvUpCb : 升场玩回调
    callback4 : 不到当前场的最低标准
    callback5 : 金币满足当前场的条件
}
]]
function M:__handleSettle(args)
    local minCoin = 1000
    local myCoin = Game.playerDB:getPlayerCoin()
    local roomId = Game.DDZPlayDB:getRoomId()
    local roomStage = roomId%100
    local bankCoin = Game.safeboxDB:getBankCoin()

    print(myCoin , roomId)
    if (myCoin+bankCoin) < minCoin then
        -- 补偿
        --print("myCoin < minCoin")
        Game.RechargeCom:checkSystemAwards(1000 , args.cpsSucs , args.cpsFail,true)
    elseif myCoin < minCoin then
        local str = string.format("您还缺少%d金币进入游戏,请从银行取出相应金币进行游戏",minCoin-myCoin)
        if IS_IOS_TS then
            str = string.format("您还缺%d金币可进入房间",minCoin-myCoin)
        end
         Game.DDZPlayCom:playerLeave(
            function()
                Game:openGameWithIdx(SCENCE_ID.PLATEFORM)
                Game:tipMsg(str,1)
            end)
    elseif myCoin < Game.DDZPlayDB:getDDZLimitMin(roomId) then
        -- 不到当前场的最低标准

        execute(args.callback4)
    elseif myCoin <= Game.DDZPlayDB:getDDZLimitMax(roomId)
        or Game.DDZPlayDB:getDDZLimitMax(roomId) == 0 then
        -- 不超过当前场的上限，可以直接开始游戏
        print("myCoin <= RoomConfig.limit_max(roomId)")
        execute(args.callback5)
    elseif myCoin > Game.DDZPlayDB:getDDZLimitMax(roomId)
        and Game.DDZPlayDB:getDDZLimitMax(roomId) ~= 0 then
        -- 超过当前场的上限，弹出升场玩提示
        print("myCoin > RoomConfig.limit_max(roomId)")
        self:showLvUpRoomTips(args.lvUpCb)
    end
end

-- 弹出是否降场选择框
function M:showDemotionRcgTips()
    local roomId = Game.DDZPlayDB:getRoomId()
    print("roomId:",roomId)
    local mix_id = RoomConfig.enter_id(roomId)
    local curCoin = Game.playerDB:getPlayerCoin()
    local needCoin = Game.DDZPlayDB:getDDZLimitMin(roomId)

    local flag = 1
    self:handleLackCoinDialog(mix_id , needCoin - curCoin , function()
        -- body
        local successCb = function ()
            -- body
            self:goOnReady()
        end
        local cancelCb = function()
            self:demotion()
        end
        if not self:handleShowLimitPackage(false,successCb,cancelCb) then
            self:demotion()
        end
    end , function()
        -- 充值成功的回调,关闭当前对话框,继续当前场
        self:goOnReady()

    end , flag)

end

-- 降场玩耍
function M:demotion()
    Game.DDZPlayCom:enterLowerRoom()
end

function M:goOnReady(showCoinRain,islower)
    local roomId = Game.DDZPlayDB:getRoomId()
    Game.DDZPlayCom:enterReadyRoom(roomId,false,false,islower)
    if showCoinRain then
        Game:dispatchCustomEvent(GlobalEvent.GAME_MONEY_MODIFY_EVENT)
        Game.tinyCom:coinRain(Game:getNowScenceObj())
    end
end

-- 升场玩耍
function M:upgrade()
    self:enterHigherRoom()
end

function M:showLvUpRoomTips(callback)
    local roomId = self:getMyFitRoom()
    local roomName = RoomConfig.name(roomId)
    local modalDialog = require_ex("ui.common.ModalDialog").new(nil , {bValid = true})
    local param = {
        callback2 = function(sender)
            -- 确认升场玩耍
            sender:destroy()
            execute(callback)
        end,
        isAlign = true,
        content = "您的金币超出房间限制,推荐您进入",
        bValid = true,
        upgrade = {roomName=roomName,callback=function()
            local taskPokeView = require_ex("ui.mission.TaskPokeView").new(roomId):addToScene(UIZorder.PopWin-1)
        end}
    }
    modalDialog:setButtonText(2 , "升场玩")
    modalDialog:init(param):addToScene()
end

function M:getMyFitRoom()
    local roomType = Game.DDZPlayDB:getRoomType()
    local myCoin = Game.playerDB:getPlayerCoin()
    return self:getFitRoom(myCoin , roomType)
end

function M:openSystemAssistUI()
    local systemAssistUI = require_ex("ui.common.SystemAssistUI").new():addToScene(UIZorder.Dialog)
    return systemAssistUI
end

--打开奖池奖励界面
function M:openJackpotResultUI(infoData)
    require_ex("games.ddz.views.DDZJackpotResultUI").new(infoData):addToScene(UIZorder.Dialog)
end

--打开规则说明界面
function M:openJackpotRuleUI()
    require_ex("games.ddz.views.DDZJackpotRuleUI").new():addToScene(UIZorder.Dialog)
end

--打开奖池赛新手引导
function M:openJackpotGuide()
    require_ex("games.ddz.views.DDZJackpotGuideUI").new():addToScene(UIZorder.Dialog)
end

--玩家信息状态变更 （暂时为机器人魔法表情金币消耗）
function M:onPokePlayerStateChange(players)
    Game.DDZPlayDB:refershDDZPlayers(players)
    if self._playUi then
        self._playUi:onPlayerCoinChange()
    end
end

--是否匹配到桌子
function M:onMatchTable(info)
    --匹配失败退出房间
    if info.ret_code == 0 then  --尚未匹配，可以退出
        self:gameBack()
    else
        Game:tipMsg("匹配成功")
    end
end

--牌局推送
function M:onPokeRoundNotify(info)
    if self._playUi then
        self._playUi:showPokeRoundInfo(info)
    end
end

--确定地主后地主倍数翻倍
function M:onEnsureLandLord(viewPos)
    if Game.DDZPlayDB:isLandLord() then
        if self._playUi then
            self._playUi:showBeishu(viewPos,2)
        end
    end
end

return M:new()