-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36

local M = class("DDZPaiXing")

function M:ctor()
    self._pokeType = nil
    self._feijiNum = nil
    self._shunNum = nil
end

function M:clearCheckType()
    self._beginNum = nil
    self._pokeType = nil
    self._feijiNum = nil
    self._shunNum = nil
end

function M:getCheckType()
    return self._pokeType
end

function M:getBeginNum()
    return self._beginNum
end

function M:getFeiJiNum()
    return self._feijiNum
end

function M:getShunNum()
    return self._shunNum
end

function M:fourWithTwoPair(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum ~= 8 then
        return nil
    end
    local pokes = self:findSamePokeWithNum(4, dataClone)

    if pokes == nil then
        return nil
    end
    Game.DDZUtil:clearTableBySeq(pokes, dataClone)

    local testPoke = self:findSamePokeWithNum(4,dataClone)
    if testPoke ~= nil then --两个炸不使用炸弹带两对
        return nil
    end

    for i=1,2 do
        pokes = self:findSamePokeWithNum(2, dataClone)
        if pokes ~= nil then
            Game.DDZUtil:clearTableBySeq(pokes, dataClone)
        else
            return nil
        end
    end

    self:setFitPaixin(PaiXing.CARD_TYPE_SI_DAN_ER2)
    return pokeData
end

function M:fourWithTwoSingle(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum ~= 6 then
        return nil
    end
    local pokes = self:findSamePokeWithNum(4, dataClone)
    local num = nil
    if pokes ~= nil then
        num = dataClone[pokes[1]].num
    else
        return nil
    end

    Game.DDZUtil:clearTableByNum(num, dataClone)

    if table.nums(dataClone) == 2 then
        local wangZha = true
        for k,v in pairs(dataClone) do
            if v.num < 16 then
                wangZha = false
            end
        end
        if wangZha then
            return nil
        end
        self:setFitPaixin(PaiXing.CARD_TYPE_SI_DAN_ER1)
        return pokeData
    end
    return nil
end

--@ 获取顺子牌
function M:findShunZi(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local pokesNum = #dataClone
    local fromKey = pokesNum
    local retPokes = {}
    if pokesNum < 5 then
        return nil
    end
    table.sort(dataClone, function(a, b)
        return a.num < b.num
    end)

    local isLianXu = true
    local needNum = dataClone[1].num
    for i,v in ipairs(dataClone) do
        if v.num > 14 then
            return nil
        end
        if v.num ~= needNum then
            isLianXu = false
            break
        else
            table.insert(retPokes, v)
            needNum = needNum + 1
        end
    end

    if isLianXu == true and pokesNum == #retPokes then
        self._shunNum = pokesNum
        self:setFitPaixin(PaiXing.CARD_TYPE_DAN_SHUN)
        return retPokes
    end
    return nil
end

function M:findThreeWithDouble(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    if pokesNum < 5 then
        return nil
    end
    local retPokes = {}
    local pokes = self:findSamePokeWithNum(3, dataClone)
    local num = nil
    if pokes ~= nil then
        num = dataClone[pokes[1]].num
    else
        return nil
    end

    Game.DDZUtil:clearTableByNum(num, dataClone)
    pokes = self:findSamePokeWithNum(2, dataClone)

    if table.nums(pokes) == 2 then
        self:setFitPaixin(PaiXing.CARD_TYPE_SAN_DAI_ER)
        return pokeData
    end
    return nil
end

function M:setFitPaixin(inType, beginNum)
    self._pokeType = inType
    self._beginNum = beginNum
end

function M:findFeiJiPoke(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum % 3 == 1 then
        return nil
    end

    local pokeNumTab = {}

    while table.nums(dataClone) > 0 do
        local pokes = self:findSamePokeWithNum(3, dataClone)

        if pokes ~= nil then
            for k,v in pairs(pokes) do
                table.insert(retPokes, v)
            end
            local num = dataClone[pokes[1]].num
            table.insert(pokeNumTab, num)
            Game.DDZUtil:clearTableByNum(num, dataClone)
        else
            return nil
        end
    end

    table.sort(pokeNumTab, function(a, b)
             return a < b
        end)

    local isLianXu = true
    local needNum = pokeNumTab[1]
    for i,v in ipairs(pokeNumTab) do
        if v > 14 then
            return nil
        end
        if v ~= needNum then
            isLianXu = false
        else
            needNum = needNum + 1
        end
    end

    if #retPokes == pokeNum and isLianXu then
        self:setFitPaixin(PaiXing.CARD_TYPE_FEI_JI)
        self._feijiNum = #pokeNumTab
        return retPokes
    end
    return nil
end

function M:findFeiJiWithOne(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)

    --现在策略一旦牌里有炸弹，则判断不是飞机牌型,配合AI
    local pokes = self:findSamePokeWithNum(4,dataClone)
    if pokes ~= nil then
        return nil
    end

    local pokeNum = #dataClone

    --三带一必是4的倍数
    if pokeNum%4 ~= 0 then
        return nil
    end

    local threeCardCount = pokeNum/4        --三带一的坎数

    local pokeNumTab = {}

    while table.nums(dataClone) > 0 do
        local pokes = self:findSamePokeWithNum(3, dataClone)

        if pokes ~= nil then
            for k,v in pairs(pokes) do
                table.insert(retPokes, v)
            end
            local num = dataClone[pokes[1]].num
            table.insert(pokeNumTab, num)
            Game.DDZUtil:clearTableByNum(num, dataClone, 3)
        else
            break
        end
    end

    table.sort(pokeNumTab, function(a, b)
             return a < b
        end)

    local count = 0
    local curValue = pokeNumTab[1]
    for i,v in ipairs(pokeNumTab) do
        if v > 14 then -- 2 大小王
            return nil
        end
        if v ~= curValue then  --不连续的两张牌，则修改当前牌，继续查找
            count = 1
            curValue = v+1
        else
            curValue = curValue + 1
            count = count + 1
            if count == threeCardCount then --有可能count超过threeCardCount，需判断满足条件直接退出循环
                break
            end
        end
    end

    if count == threeCardCount then
        self:setFitPaixin(PaiXing.CARD_TYPE_CHI_BANG1)
        self._feijiNum = count
        return pokeData
    end
    return nil
end

function M:findFeiJiWithTwo(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone

    local pokeNumTab = {}

    while table.nums(dataClone) > 0 do
        local pokes = self:findSamePokeWithNum(3, dataClone)

        if pokes ~= nil then
            for k,v in pairs(pokes) do
                table.insert(retPokes, v)
            end
            local num = dataClone[pokes[1]].num
            table.insert(pokeNumTab, num)
            Game.DDZUtil:clearTableBySeq(pokes, dataClone)
        else
            break
        end
    end

    table.sort(pokeNumTab, function(a, b)
             return a < b
        end)

    local isLianXu = true
    local needNum = pokeNumTab[1]
    for i,v in ipairs(pokeNumTab) do
        if v > 14 then
            return nil
        end
        if v ~= needNum then
            isLianXu = false
            break
        else
            needNum = needNum + 1
        end
    end
    if not isLianXu then
        return nil
    end

    local feijiNum = #pokeNumTab

    if #dataClone == (feijiNum*2) then
        for i=1,feijiNum do
            local pokes = self:findSamePokeWithNum(2, dataClone)
            if pokes ~= nil then
                Game.DDZUtil:clearTableBySeq(pokes, dataClone)
            end
        end
        if table.nums(dataClone) == 0 then
            self:setFitPaixin(PaiXing.CARD_TYPE_CHI_BANG2)
            self._feijiNum = feijiNum
            return pokeData
        end
    end
    return nil
end

function M:findThreeOrMoreDoublePoke(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum % 2 == 1 then
        return nil
    end
    if pokeNum < 6 then
        return nil
    end

    local pokeNumTab = {}

    while table.nums(dataClone) > 0 do
        local pokes = self:findSamePokeWithNum(2, dataClone)

        if pokes ~= nil then
            for k,v in pairs(pokes) do
                table.insert(retPokes, v)
            end
            local num = dataClone[pokes[1]].num
            table.insert(pokeNumTab, num)
            Game.DDZUtil:clearTableByNum(num, dataClone)
        else
            return nil
        end
    end

    table.sort(pokeNumTab, function(a, b)
        return a < b
    end)

    local isLianXu = true
    local needNum = pokeNumTab[1]
    for i,v in ipairs(pokeNumTab) do
        if v > 14 then
            return nil
        end
        if v ~= needNum then
            isLianXu = false
        else
            needNum = needNum + 1
        end
    end

    if #retPokes == pokeNum and isLianXu then
        self:setFitPaixin(PaiXing.CARD_TYPE_LIAN_DUI)
        self._shunNum = pokeNum/2
        return retPokes
    end
    return nil
end

function M:findTwoJoker(inData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local allNum = table.nums(dataClone)
    if allNum ~= 2 then
        return nil
    end
    for k,data in pairs(dataClone) do
        local num = data.num
        if num == BIG_JOKER then
            table.insert(retPokes, k)
        elseif num == SMALL_JOKER then
            table.insert(retPokes, k)
        end
    end
    if #retPokes == 2 then
        if allNum == 2 then
            self:setFitPaixin(PaiXing.CARD_TYPE_WANG_ZHA)
        end
        return retPokes
    end
    return nil
end

function M:findSamePokeWithNum(sameNum, inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    local retPokes = {}

    if pokesNum < sameNum then
        return nil
    end

    for i=pokesNum, 1, -1  do
        local nowData = dataClone[i]
        local nowNum = nowData.num
        local resultOk = true

        for j=1, sameNum-1 do
            local compareIndex = i+j
            if compareIndex > pokesNum then
                resultOk = false
                break
            end
            local compareData = dataClone[compareIndex]
            local compareNum = compareData.num

            if compareNum ~= nowNum then
                resultOk = false
                break
            end
        end

        if resultOk == true then
            for j=0, sameNum-1 do
                table.insert(retPokes, i + j)
            end
            return retPokes
        end
    end
    return nil
end

function M:findThree(inData)
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    if pokesNum < 3 then
        return nil
    end
    local retPokes = {}
    local pokes = self:findSamePokeWithNum(3, dataClone)
    if pokes ~= nil then
        for k,v in pairs(pokes) do
            table.insert(retPokes, v)
        end
    else
        return nil
    end

    local retPokeNum = #retPokes
    if retPokeNum == 3 then
        self:setFitPaixin(PaiXing.CARD_TYPE_SAN_ZHANG, pokeData[1].num)
        return retPokes
    end
    return nil
end

function M:findDoublePoke(inData)
    local retPokes = {}
    local pokeData = inData
    local allNum = table.nums(pokeData)

    local pokes = self:findSamePokeWithNum(2, inData)
    if pokes ~= nil then
        for k,v in pairs(pokes) do
            table.insert(retPokes, v)
        end
    else
        return nil
    end
    if #retPokes == 2 then
        self:setFitPaixin(PaiXing.CARD_TYPE_SHUANG, pokeData[1].num)
        return retPokes
    end
    return nil
end

function M:findOnePoke(inData)
    local retPokes = {}
    local pokeData = inData

    local allNum = table.nums(pokeData)
    if allNum > 0 then
        local pokes = {allNum}
        if pokes ~= nil then
            for k,v in pairs(pokes) do
                table.insert(retPokes, v)
            end
        else
            return nil
        end
    end

    if #retPokes == 1 then
        self:setFitPaixin(PaiXing.CARD_TYPE_DAN_ZHANG, pokeData[1].num)
        return retPokes
    end
    return nil
end

function M:findThreeWithOne(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    if pokesNum < 4 then
        return nil
    end
    local retPokes = {}
    local pokes = self:findSamePokeWithNum(3, dataClone)
    local num = nil
    if pokes ~= nil then
        num = dataClone[pokes[1]].num
    else
        return nil
    end

    Game.DDZUtil:clearTableByNum(num, dataClone)

    if table.nums(dataClone) == 1 then
        self:setFitPaixin(PaiXing.CARD_TYPE_SAN_DAI_YI)
        return pokeData
    end
    return nil
end

function M:findBomb(inData)
    local retPokes = {}
    local pokeData = inData

    local pokesNum = #pokeData
    if pokesNum == 2 then
        local pokes = self:findTwoJoker(pokeData)
        if pokes ~= nil then
            self:setFitPaixin(PaiXing.CARD_TYPE_WANG_ZHA)
            return pokes
        end
    else
        local pokes = self:findSamePokeWithNum(4, pokeData)
        if pokes ~= nil then
            self:setFitPaixin(PaiXing.CARD_TYPE_ZHA_DAN)
            return pokeData
        end
    end
    return nil
end
return M
