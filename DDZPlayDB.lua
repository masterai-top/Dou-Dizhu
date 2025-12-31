-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-09-15 12:08:32


local M = class("DDZPlayDB")

cc.exports.DDZStage = {
    MoneyShopUi = 1,
    ItemShopUi = 2,
}

cc.exports.DDZRoomType = {
    CLASSIC      = 1,
    LAIZI        = 2,
    MATCH        = 3,
    HERO_CLASSIC = 4,
    HERO_LAIZI   = 5,
    NEW_MATCH1   = 6,
    NEW_MATCH2   = 7,
    NEW_MATCH3   = 8,
    WITHOUT_WASH = 11,      --不洗牌
    JACKPOT_MATCH = 12,     --奖池赛
}

--斗地主操作状态 （叫地主 抢地主 不叫 超级加倍 加倍 不加倍 明牌 不出 不抢）
cc.exports.DDZ_OPState = {
    ["ddz_mingpai"]     = "subgame/ddz/front/ddz_mingpai.png",
    ["ddz_qiang_dizhu"] = "subgame/ddz/front/ddz_qiangdizhu.png",
    ["ddz_bu_qiang"]    = "subgame/ddz/front/ddz_buqiang.png",
    ["ddz_bu_chu"]      = "subgame/ddz/front/ddz_buchu.png",
    ["ddz_bu_jiao"]     = "subgame/ddz/front/ddz_bujiao.png",
    ["ddz_jiao_dizhu"]  = "subgame/ddz/front/ddz_jiaodizhu.png",
    ["ddz_not_jiabei"]  = "subgame/ddz/front/ddz_bujiabei.png",
    ["ddz_jiabei"]      = "subgame/ddz/front/ddz_jiabei.png",
    ["ddz_super_jiabei"]= "subgame/ddz/front/ddz_chaojijiabei.png",
    ["ddz_yaobuqi"]     = "subgame/ddz/front/ddz_yaobuqi.png",
}

local DDZSkillType = {
    T_JIAO_DIZU         = 1,    -- 1:叫地主
    T_HUODE_POKE        = 2,    -- 2:获得牌(2或者王)
    T_POKE_NUM          = 3,    -- 3:手牌显示
    T_DIPAI             = 4,    -- 4:底牌操作
    T_LAIZI             = 5,    -- 5:癞子牌操作
    T_WIN_JIA_JINBI     = 6,    -- 6:赢得牌局后，对方每张牌新增金币
    T_LOST_JIAN_JINBI   = 7,    -- 7:输得牌局后，自己已出牌减免金币
    T_TIMES             = 8,    -- 8:出牌时间增减
    T_PX_ADD_JINBI      = 9,    -- 9:特殊牌型增加金币
    T_DOUBLE_ADD        = 10,   -- 10:加倍倍数增加
    T_MINGPAI_JINBI     = 11,   -- 11:明牌后输赢金钱数变化
    T_FINISH_PAI        = 12,   -- 12:无人跟牌
    T_HUANG_DIPAI       = 13,   -- 13:底牌操作
    T_KAN_SHOU_PAI      = 14,   -- 14:看手牌
    T_BREZZ_SHOU_PAI    = 15,   -- 15:冻手牌
}
cc.exports.DDZSkillType = DDZSkillType

local SkillEffType = {
    ET_JIAO_DIZU           = 1,
    ET_HUODE_POKE          = 2,
    ET_POKE_NUM            = 3,
    ET_KAN_DIPAI           = 4,
    ET_HUANG_DIPAI         = 5,
    ET_KAN_LAIZI           = 6,
    ET_HUANG_LAIZI         = 7,
    ET_WIN_ZENGJIA_JINBI   = 8,
    ET_LOST_JIAN_JINBI     = 9,
    ET_XIUGAI_SHIJIAN      = 10,
    ET_PX_ADD_JINBI        = 11,
    ET_DOUBLE_ADD          = 12,
    ET_MINGPAI_JINBI       = 13,
    ET_FINISH_PAI          = 14,
    ET_KAN_SHOU_PAI        = 15,
    ET_BREZZ_SHOU_PAI      = 16,
}
cc.exports.DDZSkillEffType = SkillEffType

local DDZTaskScene =
{
    ClassFirst      = 44, -- 经典初级场
    ClassSecond     = 45, -- 经典普通场
    ClassThird      = 46, -- 经典高级场
    ClassFourth     = 47, -- 经典顶级场

    LaiziFirst      = 48, -- 癞子初级场
    LaiziSecond     = 49, -- 癞子普通场
    LaiziThird      = 50, -- 癞子高级场
    LaiziFourth     = 51, -- 癞子顶级场

    HeroClassFirst  = 52, -- 经典初级场
    HeroClassSecond = 53, -- 经典普通场
    HeroLaiziFirst  = 54, -- 癞子高级场
    HeroLaiziSecond = 55, -- 癞子顶级场
}
cc.exports.DDZTaskScene = DDZTaskScene

local DEBUG_TEST = false
local DEBUG_GUIDE = false

function M:ctor()
    self:init()

    -- 用于比赛场及时计时显示
    self._timeList = {
        {math.random(24) , 24.99},
        {math.random(24) , 24.99},
        {math.random(48) , 48.99},
        {math.random(48) , 48.99},
    }
end

function M:init()
    self._roomType = 1
    self._roomID = 0

    self:clearOldData()
    self._matchPoint = 0
    self._matchLevel = 1
    self._inPlaying = false
    -- 游戏房间人数列表
    self._roomList = {}
end

function M:isSatisfyRoomCoin()
    local myCoin = self:getDDZCoinNum(self:getRoomId())
    local minCoin = self:getDDZLimitMin(self:getRoomId())
    return myCoin >= minCoin
end

function M:clearOldData()
    self._landLordPos = nil
    self._myPos = nil
    self._myUse_note = 0
    self._doublesInfo = {}

    self._ddzPlayers = {}

    self._tuoguan = 0
    self._firstDZ = true
    self._mapSvrPosToViewPos = {}
    self._netPokeData = {}
    self._selectedPokes = {}
    self._roundState = nil

    self._beforeDialMP = {}
    self._roundMyTurn = false
    self._roundPokes = nil
    self._roundHasLZ = false

    self._lastMyGoPokeType = nil
    self._laiZiPoke = nil
    self._laiZiNum = nil
    self._nowPokes = {0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,1,1}

    self._nowPokeSpan = 60
    self._virtualBoxNum = 0
    self._mybox_list = {}

    self._is_end_laizi = false
    self._play_round = 0
    self._is_look_dipai = false -- 是否已看过底牌
    self._pokeData = {}
end

function M:update(dt)
    for __, val in ipairs(self._timeList) do
        local curTime = val[1]
        local maxTime = val[2]
        curTime = curTime - dt
        curTime = curTime >= -3 and curTime or maxTime
        val[1] = curTime
    end
end

function M:setRoomId(roomId)
    local baiRoom = math.floor(roomId/100)
    if baiRoom == 1 then
        self:setRoomType(DDZRoomType.CLASSIC)

    elseif baiRoom == 2 then
        self:setRoomType(DDZRoomType.LAIZI)

    elseif baiRoom == 3 then
        self:setRoomType(DDZRoomType.MATCH)

    elseif baiRoom == 4 then
        self:setRoomType(DDZRoomType.HERO_CLASSIC)

    elseif baiRoom == 5 then
        self:setRoomType(DDZRoomType.HERO_LAIZI)

    elseif baiRoom == 6 then
        self:setRoomType(DDZRoomType.NEW_MATCH1)

    elseif baiRoom == 7 then
        self:setRoomType(DDZRoomType.NEW_MATCH2)

    elseif baiRoom == 8 then
        self:setRoomType(DDZRoomType.NEW_MATCH3)

    elseif baiRoom == 11 then
        self:setRoomType(DDZRoomType.WITHOUT_WASH)

    elseif baiRoom == 12 then
        self:setRoomType(DDZRoomType.JACKPOT_MATCH)
    end
    self._roomID = roomId
    self._play_round = 0

    Game.DDZPlayCom:changeRules()

    Log(LOG.TAG.DDZ, LOG.LV.INFO, "===DDZPlayDB setRoomId roomId is: " .. tostring(roomId))
end

function M:getRoomId()
    return self._roomID
end

function M:getRoomLv()
    local lv = self._roomID%100

    if self:getIsHeroClassicRoom() then
        return (lv+8)

    elseif self:getIsHeroLaiZiRoom() then
        return (lv+10)

    elseif self:getIsClassicRoom() then
        return lv

    elseif self:getIsLaiZiRoom() then
        return (lv+4)
        
    elseif self:getIsWithoutWashRoom() then
        return lv

    elseif self:getIsJackpotMatchRoom() then
        return lv
    end
    return 0
end

function M:isCompetitionRoom(roomId)
    local _type = RoomConfig.type(roomId)
    return (_type == 3 or _type == 6 or _type == 7 or _type == 8)
end

function M:setRoomType(type)
    self._roomType = type
end

function M:getRoomType()
    return self._roomType
end

function M:setLookDipai(_look)
    self._is_look_dipai = _look
end

function M:isLookDipai()
    return self._is_look_dipai
end

function M:getIsClassicRoom()
    return (self._roomType == DDZRoomType.CLASSIC)
end

function M:getIsLaiZiRoom()
    return ((self._roomType == DDZRoomType.LAIZI)
        or self:getIsHeroLaiZiRoom())
end

function M:getIsGoodsMatchRoom()
    return (self._roomType == DDZRoomType.MATCH)
end

function M:getIsMatchRoom()
    return (self._roomType == DDZRoomType.MATCH)
            or (self._roomType == DDZRoomType.NEW_MATCH1)
            or (self._roomType == DDZRoomType.NEW_MATCH2)
            or (self._roomType == DDZRoomType.NEW_MATCH3)
end

function M:getIsHeroRoom()
    return (self._roomType == DDZRoomType.HERO_CLASSIC
        or self._roomType == DDZRoomType.HERO_LAIZI)
end

function M:getIsHeroClassicRoom()
    return (self._roomType == DDZRoomType.HERO_CLASSIC)
end

function M:getIsHeroLaiZiRoom()
    return (self._roomType == DDZRoomType.HERO_LAIZI)
end

function M:getIsHeroMatchRoom()
    return false
end

function M:getIsWithoutWashRoom()
    return (self._roomType == DDZRoomType.WITHOUT_WASH)
end

function M:getIsJackpotMatchRoom()
    return (self._roomType == DDZRoomType.JACKPOT_MATCH)
end

function M:getDDZTaskScene()
    if self._roomID and RoomConfig[self._roomID] then
        return RoomConfig.task_scene(self._roomID)
    end
    return 0
end

-------------- Game Data --------------
function M:getPlayerCoin()
    return Game:GetModel(Model.PLAYER):getPlayerCoin()
end
---------------------------------------

function M:isMyPos(pos)
    if self._myPos == pos then
        return true
    else
        return false
    end
end

function M:isFriendPos(pos)
    if self._myPos == pos then
        return true
    end
    -- 我是地主
    if self:isLandLord() then
        return false
    end
    -- 我是农民
    local station = 0
    for k,v in pairs(self._ddzPlayers) do
        if v.pos == pos then
            station = v.station
        end
    end
    if station == 1 then
        return true
    end
    return false
end

function M:setMyPos(pos)
    self._myPos = pos
end

function M:getMyPos()
    return self._myPos
end

function M:setMyUseNote(isUse)
    self._myUse_note = isUse
end

function M:getMyUseNote()
   return self._myUse_note
end

function M:getTimeList()
    return self._timeList
end

function M:setRoomNumList(list)
    self._roomList = list or {}
end

-- 获取首页游戏人数数量
function M:getGameNumList()
    local ret = {}
    for __ , val in ipairs(self._roomList) do
        if val.id < 10 then
            ret[val.id] = val
        end
    end
    return ret
end

function M:setVirtualBoxNum(num)
    self._virtualBoxNum = num
end

function M:addVirtualBoxNum(num)
    self._virtualBoxNum = self._virtualBoxNum + num
end

function M:getVirtualBoxNum()
    return self._virtualBoxNum
end

function M:getClassicNumList()
    local ret = {}
    if not self._roomList then
        return
    end
    for __ , val in ipairs(self._roomList) do
        if val.id > 99 and val.id < 199 then
            ret[val.id] = val
        end
    end
    return ret
end

function M:getHeroNumList()
    local ret = {}
    if not self._roomList then
        return
    end
    for __ , val in ipairs(self._roomList) do
        if val.id > 400 and val.id < 599 then
            ret[val.id] = val
        end
    end
    return ret
end

function M:getLaiZiNumList()
    local ret = {}
    if not self._roomList then
        return
    end
    for __ , val in ipairs(self._roomList) do
        if val.id > 199 and val.id < 299 then
            ret[val.id] = val
        end
    end
    return ret
end

function M:getMatchNumList()
    local ret = {}
    for __ , val in ipairs(self._roomList) do
        if val.id > 100 then
            if self:isCompetitionRoom(val.id) then
                ret[val.id] = val
            end
        end
    end
    return ret
end

function M:initPokeData(netPokeData)
    self._netPokeData = netPokeData
    self:setPokesData(netPokeData)

    self._selectedPokes = {}
    local data = {pos = self._myPos}
    Game.DDZPlayCom:onChangePokerInfo(data)
end

function M:changePokeData(old_num, card_num)
    local change_idx = 0
    for i,v in ipairs(self._netPokeData or {}) do
        if v == old_num then
            change_idx = i
        end
    end
    if self._netPokeData[change_idx] then
        self._netPokeData[change_idx] = card_num
    end
    self._selectedPokes = {}
    table.sort(self._netPokeData, function(a, b)
        return a > b
    end)
    self:setPokesData(self._netPokeData)

    for i,v in ipairs(self._netPokeData or {}) do
        if v == card_num then
            change_idx = i
        end
    end
    Game.DDZPlayCom:onChangePokerInfo({pos = self._myPos, change_idx = change_idx})
    -- self:setPokesData(self._netPokeData)
    -- Game.DDZPlayCom:onChangePokerInfo({pos = self._myPos, delay = 1.2})
end

function M:setLandLordPos(pos)
    self._landLordPos = pos
    local viewPos = self:getViewPosWithSvrPos(pos)
    Game.DDZPlayCom:onEnsureLandLord(viewPos)
end

function M:isLandLord()
    return (self._landLordPos == self._myPos)
end

function M:setInPlaying(value)
    self._inPlaying = value
end

function M:isInPlaying()
    return self._inPlaying
end

function M:getBeforeDialMP()
    return self._beforeDialMP
end

function M:clearBeforeDialMP()
    self._beforeDialMP = {}
end

function M:setNowPokeSpan(span)
    self._nowPokeSpan = span
end

function M:getNowPokeSpan()
    return self._nowPokeSpan
end

function M:setMyTurn(value)
    self._roundMyTurn = value
end

function M:getMyTurn()
    return self._roundMyTurn
end

function M:onGameEnd(info)
    local playerResult = info.player_data
    local myPoint = 0
    for k,v in pairs(playerResult) do
        local pos = v.pos
        local player = self._ddzPlayers[pos]
        if player then
            player.cards = v.cards
            player.point = v.point

            if self._myPos == pos then
                myPoint = v.point

            elseif player.opendeal ~= 1 then
                player.pokeData = Game.DDZPlayCom:converSvrPokeToClient(player.cards)
            end
        end
    end
    Game.DDZPlayDB:setMatchPoint(myPoint)
    Game.DDZPlayCom:onMingPaiDataNew(true)
    self:setMyTuoGuanState(0)
end

function M:setSelectedPoke(data)
    self._selectedPokes = data
end

function M:getSelectedPoke()
    return self._selectedPokes
end

function M:getLastMyGoPokeType()
    return self._lastMyGoPokeType
end

function M:setLastMyGoPokeType(type)
    self._lastMyGoPokeType = type
end

function M:setMatchLevel(level)
    self._matchLevel = level
end

function M:getMatchLevel()
    return self._matchLevel
end

function M:setMatchPoint(point)
    self._matchPoint = point
    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_MATCH_POINT_EVENT, {point = point})
end

function M:setLaiZiPoke(netNum)
    if DEBUG_TEST == true then
        netNum = 81
    end

    self._laiZiNum = math.floor(netNum/10)
    self._laiZiPoke = Game.DDZPlayCom:converSvrPokeToClient({netNum})

    self:onPokeDataChange(1, {}, self._myPos, true)
end

function M:getLaiZiPoke()
    return self._laiZiPoke
end

function M:getLaiZiNum()
    return self._laiZiNum
end

function M:checkIsLaiZiNum(num)
    return (self._laiZiNum == num)
end

function M:addPlayRound()
    self._play_round = self._play_round+1
end

function M:isThirdRound()
    return (self._play_round == 3)
end

function M:setIsEndLaiZi(is_end)
    self._is_end_laizi = is_end
end

function M:isEndLaiZi()
    return self._is_end_laizi
end

function M:isAlarmStatus()
    local nowPokes = self:getNowPokeNum()
    if nowPokes <= 3 then
        return true
    else
        return false
    end
end

function M:setTuoguan(pos, state)
    if not self._ddzPlayers[pos] then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, string.format("===DDZPlayDB setTuoguan pos %s player is null===", tostring(pos)))
        return
    end
    if pos == self._myPos then
        self._tuoguan = state
        if self._tuoguan == 1 then
            Game.DDZPlayCom:doUnSelectAllPokes()
        end
        Game.DDZPlayCom:setTuoGuanMaskPoke((self._tuoguan == 1))
    end
    local ddzState = (state == 0 and 2) or 3
    self._ddzPlayers[pos].state = ddzState
    print("DDZPlayDB:setTuoguan!!!")
    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_TUOGUAN_UPDATE_EVENT, {refresh = true})
end

function M:setMyTuoGuanState(state)
    if not self._ddzPlayers[self._myPos] then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, string.format("===DDZPlayDB setMyTuoGuanState pos %s player is null===", tostring(self._myPos)))
        return
    end
    self._tuoguan = state
    if self._tuoguan == 1 then
        Game.DDZPlayCom:doUnSelectAllPokes()
    end
    Game.DDZPlayCom:setTuoGuanMaskPoke((self._tuoguan == 1))

    local ddzState = (state == 0 and 2) or 3
    self._ddzPlayers[self._myPos].state = ddzState

    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_TUOGUAN_UPDATE_EVENT, {refresh = true})
end

function M:getTuoguanState()
    return self._tuoguan
end

function M:isTuoguan()
    local isTuoguan = false
    if self._tuoguan == 1 then
        isTuoguan = true
    end
    return isTuoguan
end

function M:setDiPai(dipai, laizipai)
    self._dipais = dipai
    self._laizipais = laizipai
end

function M:getDiPai()
    return self._dipais, self._laizipais
end

function M:setMP(pos, value)
    if self._ddzPlayers[pos] then
        self._ddzPlayers[pos].opendeal = value
        if pos == self._myPos then
            local data = {pos = self._myPos}
            Game.DDZPlayCom:onEvent(DDZEvent.DDZ_SELF_MP_EVENT, data)
        end
    end
end

function M:setPlayerSkin(skin)
    local player = self._ddzPlayers[self._myPos]
    if player then
        player.skin = skin
    end
end

function M:isSelfMP()
    if not self._ddzPlayers[self._myPos] then
        return false
    end
    if self._ddzPlayers[self._myPos].opendeal == 1 then
        return true
    end
    return false
end

function M:checkIsTuoguan(pos)
    if not self._ddzPlayers[pos] then
        return true
    end
    if self._ddzPlayers[pos].state == 3 then
        return true
    else
        return false
    end
end

function M:onPokeDataChange(oper, pokeList, pos, change)
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("===onPokeDataChange oper is:%s, pos is:%s, mypos is:%s===", tostring(oper), tostring(pos), tostring(self._myPos)))
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("===onPokeDataChange pokeList is:%d ", table.nums(pokeList)))
    local data = {pos = pos}
    local pokeNums = table.nums(pokeList)

    if pos == self._myPos then
        local playerData = Game.DDZPlayDB:getDDZPlayer(self._myPos)
        if oper == 0 then
            for k,v in pairs(pokeList) do
                table.removebyvalue(self._netPokeData, v, true)
            end
            if playerData then
                playerData.cards_num = playerData.cards_num - pokeNums
            end
        else
            for k,v in pairs(pokeList) do
                table.insert(self._netPokeData, v)
            end
            if pokeNums == 3 then
                data.getDP = true
            end
            if playerData then
                playerData.cards_num = playerData.cards_num + pokeNums
            end
        end
        self:setPokesData(self._netPokeData, change)
        self._selectedPokes = {}
    else
        if not self._ddzPlayers[pos] then
            Log(LOG.TAG.DDZ, LOG.LV.ERROR, string.format("===onPokeDataChange _ddzPlayers is not exist==="))
            return
        end
        local player = self._ddzPlayers[pos]
        local pokeCards = player.cards or {}

        if oper == 0 then
            for k,v in pairs(pokeList) do
                table.removebyvalue(pokeCards, v, true)
            end
            player.cards_num = player.cards_num - pokeNums
        else
            for k,v in pairs(pokeList) do
                table.insert(pokeCards, v)
            end
            player.cards_num = player.cards_num + pokeNums
        end
        if Game.DDZPlayDB:isEndLaiZi() then
            self:setPlayerPokes(pos, pokeCards, false)
        else
            self:setPlayerPokes(pos, pokeCards, true)
        end
        if pokeNums > 0 then
            Game.DDZPlayCom:getDDZEffc():playPoliceSound(player.cards_num, pos, player)
            Game.DDZPlayCom:getDDZEffc():playPolilceEffect(player.cards_num, pos, player)
        end
    end
    Game.DDZPlayCom:getPlayUi():onPokerInfoRefresh(data)
end

function M:onToPokeUIRefresh(change)
    self:setPokesData(self._netPokeData, change)
    Game.DDZPlayCom:getPlayUi():onPokerInfoRefresh({pos = self._myPos})

    if Game.DDZPlayDB:getIsLaiZiRoom() then
        for i=1,3 do
            self:onPlayerPokeDataChange(i)
        end
    end
end

function M:getPokesData()
    return self._pokeData
end

function M:setPokesData(netPokeData, change)
    if DEBUG_TEST == true then
        --local test = {41,42,43,52,52,53,61,61,62,73,71,72, 74,133,82,93,104,114,112,151,152,122}
        --local test = {41,42,43,54,51,61,61,62,73,71,72, 74,104,124,112,81,152}
        --local test = {31,32,33,33,51,61,81,91,112,152}
        -- local test = {31,32,33,34,42,43,51,52,53,54,62,63,151,152,161,171}
        -- local test = {31, 32, 33, 151, 152, 141, 131, 121, 111, 101, 102, 91, 51, 52, 41, 42, 43}
        -- local test = {72, 171, 151, 152, 141, 142, 131, 132, 133, 121, 122, 123, 101, 102, 81, 82, 61}
        local test = {82, 161, 151, 141, 142, 131, 132, 111, 112, 101, 102, 91, 92, 72, 62, 52, 42}
        self._pokeData = Game.DDZPlayCom:converSvrPokeToClient(test)
    else
        self._pokeData = Game.DDZPlayCom:converSvrPokeToClient(netPokeData, nil, change)
    end
end

function M:setRoundPokes(pokes, hasLZ)
    if DEBUG_TEST == true then
        -- local test = {111, 112, 113, 41, 44}
        -- local test = {111, 112, 113, 71}
        local test = {31, 41, 51, 61, 71}
        self._roundPokes = test
    else
        self._roundPokes = pokes
    end

    if hasLZ == true then
        self._roundHasLZ = true
    else
        self._roundHasLZ = false
    end
end

function M:getRoundPokes()
    return self._roundPokes
end

function M:isPreDaXiaoHuan()
    local poke = self._roundPokes
    if not poke or #self._roundPokes ~= 2 then
        return false
    end
    local one = self._roundPokes[1]
    local two = self._roundPokes[2]
    if one ~= SMALL_JOKER*10 and one ~= BIG_JOKER*10 then
        return false
    end
    if two ~= SMALL_JOKER*10 and two ~= BIG_JOKER*10 then
        return false
    end
    return true
end

function M:isRoundHasLZ()
    return self._roundHasLZ
end

function M:isFollowPoke()
    if self._roundState == 1 then
        return true
    end
    return false
end

function M:onPlayerPokeDataChange(pos, change)
    local step = Game.DDZPlayCom:getStep()
    if step == DDZ_Step.NO_OPEN then
        self._beforeDialMP[pos] = true
    end
    if self._myPos == pos then
        return
    end
    local player = self._ddzPlayers[pos]
    if not player then
        return
    end
    player.pokeData = Game.DDZPlayCom:converSvrPokeToClient(player.cards, nil, change)

    Game.DDZPlayCom:onMingPaiDataNew(false)
end

function M:setPlayerPokes(pos, pokes, change)
    local player = self._ddzPlayers[pos]
    if not player then return end  --容错 add by xcw

    player.cards = pokes
    self:onPlayerPokeDataChange(pos, change)
end

function M:getViewPosWithSvrPos(svrPos)
    return self._mapSvrPosToViewPos[svrPos]
end

function M:getSvrPosWithViewPos(viewPos)
    for k,v in pairs(self._mapSvrPosToViewPos) do
        if v == viewPos then
            return k
        end
    end
    return nil
end

function M:setMingPai(pos, value)
    local playerData = self._ddzPlayers[pos]
    playerData.opendeal = value
end

function M:getMingPai(pos)
    local playerData = self._ddzPlayers[pos]
    if playerData.opendeal == 1 then
        return true
    else
        return false
    end
end

function M:setRoundState(state)
    self._roundState = state
end

function M:getRoundState()
    return self._roundState
end

function M:getAntes()
    if not RoomConfig[self._roomID] then
        return 0
    end
    local retValue = RoomConfig[self._roomID].antes
    return retValue
end

function M:getJPQ()
    -- local num = self:getNowPokeNum()
    -- local check_num = 0
    -- if self:isLandLord() then
    --     check_num = 20
    -- else
    --     check_num = 17
    -- end
    -- -- 第一手牌前不剔除
    -- if (num == check_num) then
    --     return self._nowPokes
    -- end

    local showPokes = table.newclone(self._nowPokes)
    local pokeData = self:getPokesData()
    for i,v in ipairs(pokeData or {}) do
        if showPokes[v.num] then
            showPokes[v.num] = math.max(0, (showPokes[v.num]-1))
        end
    end
    return showPokes
end

function M:usePokes(pokeList)
    for k,v in pairs(pokeList) do
        local highNum = math.floor(v/10)
        self._nowPokes[highNum] = self._nowPokes[highNum] - 1
    end
    Game.DDZPlayCom:onChangeJPQUI()
end

function M:on16003(info)
    for k,v in pairs(self._ddzPlayers) do
        local nowCardNum = v.cards_num
        if nowCardNum == 0 then
            v.cards_num = 17
        end
    end
    Game.DDZPlayCom:onPokeNumChange()
end

--@我自己的宝箱
function M:setMyBoxNum(box_list)
    for i,v in ipairs(box_list or {}) do
        self:addMyBoxNum(v.num, v.goods_id)
    end
end

--@我自己的宝箱
function M:addMyBoxNum(boxNum, id)
    table.insert(self._mybox_list, {id=id, num=boxNum})
end

function M:getMyBoxNum()
    local num = 0
    for i,v in ipairs(self._mybox_list or {}) do
        num = num + v.num
    end
    return num
end

function M:getMyBoxList()
    local list = {}
    for i,v in ipairs(self._mybox_list or {}) do
        list[v.id] = list[v.id] or 0
        list[v.id] = list[v.id] + v.num
    end
    local ret = {}
    for k,v in pairs(list or {}) do
        local quality = GoodsConfig.quality(k) or 0
        table.insert(ret, {id=k, num=v, quality=quality})
    end
    local onSort = function(a, b)
        return a.quality > b.quality
    end
    table.sort(ret, onSort)
    return ret
end

function M:setFirstDiZhu(value)
    self._firstDZ = value
end

function M:getFirstDiZhu()
    return self._firstDZ
end

function M:checkIsFirstChuPai()
    local totalCards = 0
    for k,v in pairs(self._ddzPlayers) do
        totalCards = totalCards + v.cards_num
    end
    if totalCards == 54 then
        return true
    end
    return false
end

function M:clearDoubleInfo()
    self._doublesInfo = {}
end

function M:cntAllDoubles()
    local retValue = 1
    for k,v in pairs(self._doublesInfo) do
        retValue = retValue * v
    end
    return retValue
end

function M:getDoublesInfo()
    return self._doublesInfo
end

function M:setDoublesInfo(data)
    for k,v in pairs(data) do
        local type = v.tyep
        local num = v.num

        self._doublesInfo[type] = num
    end
    Game.DDZPlayCom:onChangeDoubleInfo()
end

function M:onDizhuPosChange(dizhuPos)
    self:setLandLordPos(dizhuPos)

    local list = {}
    for k,v in pairs(self._ddzPlayers) do
        local nowPos = v.pos
        local nowStation = v.station
        if nowPos == dizhuPos then
            v.station = 2
        else
            v.station = 1
        end
        table.insert(list, {pos = v.pos})
    end
    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_PLAYER_REFRESH_EVENT, list)
end

function M:refreshMyInfo()
    local myUid = Game.playerDB:getPlayerUid()
    for k,v in pairs(self._ddzPlayers) do
        local uid = v.uid
        if uid == myUid then
            self._myPos = v.pos
            self._mapSvrPosToViewPos = {}

            self:setMyBoxNum(v.drop_list)
            local posIdx = 1
            for i=0,2 do
                local nowPos = self._myPos + i
                if nowPos > 3 then
                    nowPos = nowPos % 3
                end
                self._mapSvrPosToViewPos[nowPos] = posIdx
                posIdx = posIdx + 1
            end
        end
    end
end

function M:refreshAllTuoGuan()
    for k,v in pairs(self._ddzPlayers) do
        local tgState = 0
        if v.state == 3 then
            tgState = 1
        end
        self:setTuoguan(v.pos, tgState)
    end
end

function M:setPlayerPokeNum(pos, num)
    if self._ddzPlayers[pos] ~= nil then
        self._ddzPlayers[pos].cards_num = num
    end
end

function M:setDDZPlayers(data)
    self._ddzPlayers = {}
    for k,v in pairs(data) do
        if self._ddzPlayers[v.pos] == nil or (self._ddzPlayers[v.pos].uid ~= v.uid) then
        end
        self._ddzPlayers[v.pos] = v
    end
    self:refreshMyInfo()
    self:refreshAllTuoGuan()
    for k,v in pairs(data) do
        if v.opendeal == 1 then
            self:setPlayerPokes(v.pos, v.cards, true)
        end
    end
    Game.DDZPlayCom:onChangePlayerInfo()
    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_MATCH_POINT_EVENT, {})
end

function M:refershDDZPlayers(data)
    if self._ddzPlayers then
        for k,v in pairs(data) do
            if self._ddzPlayers[v.pos] == nil or (self._ddzPlayers[v.pos].uid ~= v.uid) then
            end
            self._ddzPlayers[v.pos] = v
        end
    end
end

function M:setPlayerDoubles(pos)
    local player = self:getDDZPlayer(pos)
    if not player then return end

    local double = player.double
    player.double = double*2
end

function M:getAllPlayer()
    return self._ddzPlayers
end

function M:getPlayerData(uid)
    for key , val in pairs(self._ddzPlayers) do
        if val.uid == uid then
            return val
        end
    end
end

function M:getDDZPlayer(pos)
    return self._ddzPlayers[pos]
end

function M:getOtherPlayerCardNum(pos)
    if not self._ddzPlayers[pos] then
        return 0
    end
    return self._ddzPlayers[pos].cards_num
end

function M:isCouplePlayer(s)
    local list = {}
    local my_name = GoodsConfig.pinyin_name(s)

    for k,v in pairs(self._ddzPlayers or {}) do
        local skin = v.skin
        local name = GoodsConfig.pinyin_name(skin)
        table.insert(list, name)
    end
    if not table.isExist(list, "zhouyu")
        or not table.isExist(list, "xiaoqiao") then
        return false
    end
    if my_name ~= "zhouyu"
        or my_name ~= "xiaoqiao" then
        return false
    end
    return true
end

function M:getOnePokeWithIndex(index)
    return self._pokeData[index]
end

function M:getSelectedPokesData()
    local retPokes = {}
    for k,v in pairs(self._pokeData) do
        if v.selected == true then
            table.insert(retPokes, v)
        end
    end
    return retPokes
end

function M:getNowPokeNum()
    return #self._pokeData
end

function M:isFirstDDZ()
    local player = self:getDDZPlayer(self._myPos)
    if not player then
        return false
    end
    local count = player.win_num + player.lose_num
    Log(LOG.TAG.DDZ, LOG.LV.INFO, string.format("====check isPlayerFirstPlayCard count is:%d====", count))
    if count > 0 then
        return false
    end
    return true
end

function M:isPlayerFirstPlayCard(round)
    local not_show = true
    if not_show then
        return false
    end
    if not self:isFirstDDZ() then
        return false
    end
    if round == 1 then
        local num = self:getNowPokeNum()
        if self:isLandLord() then
            return (num == 20)
        else
            return (num == 17)
        end

    elseif round == 3 then
        return self:isThirdRound()
    end
    return false
end

-- 1,男;2,女
function M:getDDZPlayerSoundSex(player)
    if not self:getIsHeroRoom() then
        if player == nil then     --容错，避免查找不到player
            player = {}
        end
        local id = player.facelook or 0
        return Game.playerDB:getFactlookSex(id)
    end
    if not player then return 1 end

    local skin = player.skin or 0
    if skin == 0 then return 1 end
    local sex = GoodsConfig.sex(skin) or 1
    return sex
end

function M:setCurRoomNumOfPeople(num)
    self._curRoomNumOfPeople = num
end

function M:getCurRoomNumOfPeople()
    return self._curRoomNumOfPeople
end

------------------------英雄排位赛入口start--------------------

function M:setRankingList(list)
    self._rankingList = list
end

function M:getRankingList()
    return self._rankingList
end

-- 获取段位经验
function M:getTotalExp()
    return self._totalExp
end

function M:setTotalExp(exp)
    self._totalExp = exp
    self._grading , self._starNum , self._curExp = self:handleExp(exp)
end

function M:getGrading()
    return self._grading
end

function M:setGrading(val)
    self._grading = val
end

function M:setStarNum(val)
    self._starNum = val
end

-- 获取当前升级需要的经验
function M:getCurNeedExp()
    return HeroQualifyingConfig.exp_list(self._grading)[self._starNum + 1]
end

function M:getCurNeedStar()
    return #HeroQualifyingConfig.exp_list(self._grading)
end

function M:getStarNum()
    return self._starNum
end

function M:setCurExp(val)
    self._curExp = val
end

function M:getCurExp()
    return self._curExp
end

function M:handleExp(exp)
    local ids = HeroQualifyingConfig.getIds()
    local num = 0
    for __ , id in ipairs(ids) do
        local expList = HeroQualifyingConfig.exp_list(id)
        for i , val in ipairs(expList) do
            local lv = i - 1
            if num + val > exp then
                return id , lv , exp - num
            end
            num = num + val
        end
    end
end

------------------------英雄排位赛入口 end--------------------
--获取该房间需要的货币类型数量
function M:getDDZCoinNum(roomId)
    local num = 0
    local limitMin = RoomConfig.limit_min(roomId)
    local coinId = limitMin[1][1]
    if coinId then
        if coinId == 100010001 then
            num = Game.playerDB:getPlayerCoin()
        elseif coinId == 100010002 then
            num = Game.playerDB:getDiamond()
        elseif coinId == 100010003 then
            num = Game.playerDB:getPlayerRedBean()
        end
    end
    return num
end

function M:getDDZLimitMin(roomId)
    local limitMin = RoomConfig.limit_min(roomId)
    if limitMin then
        return limitMin[1][2]
    end
end

function M:getDDZLimitMax(roomId)
    local limitMax = RoomConfig.limit_max(roomId)
    if limitMax then
        return limitMax[1][2]
    end
end

function M:getDDZStartMin(roomId)
    local startMin = RoomConfig.start_min(roomId)
    if startMin then
        return startMin[1][2]
    end
end

--是否是奖池赛
function M:isJackpotMatchRoom()
    return self._roomType == DDZRoomType.JACKPOT_MATCH
end

return M:new()