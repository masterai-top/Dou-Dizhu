-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36

local chupaicando = {
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
}

local M = class("DDZPaiXingLaiZi")

function M:ctor()
    self._beginNum = nil
    self._pokeType = nil
    self._changeNum = {}
end

function M:clearCheckType()
    self._pokeType = nil
end

function M:getLaiZiChange()
    return self._changeNum
end

function M:insertLaiZiChange(value)
    table.insert(self._changeNum, value)
end

function M:clearLaiZiChange()
    self._changeNum = {}
end

function M:getBeginNum()
    return self._beginNum
end

function M:getCheckType()
    return self._pokeType
end

function M:setFitPaixin(inType, beginNum)
    self._pokeType = inType
    self._beginNum = beginNum
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
        self:clearLaiZiChange()
        return retPokes
    end
    return nil
end

function M:checkSamePokeWithNum_LZ(sameNum, inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    local retPokes = {}

    if pokesNum < sameNum then
        return nil
    end

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriData = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriData, dataClone[v])
    end
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    pokesNum = #dataClone
    if pokesNum == 0 then
        return pokeData
    else
        local num = dataClone[1].num
        local sames = Game.DDZUtil:findSamePoke(num, dataClone)
        if #sames == pokesNum then
            for k,v in pairs(oriData) do
                local laiziOne = v
                local change = Game.DDZUtil:makeLaiZiChange(laiziOne.svrNum, num)
                self:insertLaiZiChange(change)
            end
            return pokeData
        end
    end
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

function M:selectMaxInfo(pokes)
    local retInfo = {}
    local nowMax = 0
    for k,v in pairs(pokes) do
        if v.num > nowMax then
            nowMax = v.num
            retInfo.idx = k
            retInfo.value = v
        end
    end
    return retInfo
end

function M:selectDXWangPokes(pokes)
    local retPokes = {}
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    for k,v in pairs(pokes) do
        local num = v.num
        if num == BIG_JOKER then
            table.insert(retPokes, k)
        elseif num == SMALL_JOKER then
            table.insert(retPokes, k)
        end
    end
    return retPokes
end

function M:findThreeWithDouble(inData)
    self:clearLaiZiChange()
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    if pokesNum < 5 then
        return nil
    end
    local retPokes = {}
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    if #laiziPokes > 0 then
        local allNums = Game.DDZUtil:buildAllNums(pokeData)
        local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
        local oriNum = {}
        for k,v in pairs(laiziPokes) do
            table.insert(oriNum, dataClone[v].svrNum)
        end
        for kNum,vNum in pairs(allNums) do
            retPokes = {}
            self:clearLaiZiChange()
            if vNum <= TWO then
                local dataCloneTmp = table.newclone(dataClone)

                for k,v in pairs(dataCloneTmp) do
                    if v.num == vNum then
                        table.insert(retPokes, k)
                        if #retPokes == 3 then
                            break
                        end
                    end
                end
                if #retPokes == 3 then
                    Game.DDZUtil:clearTableBySeq(retPokes, dataCloneTmp)
                    local retSame = self:checkSamePokeWithNum_LZ(2, dataCloneTmp)
                    if retSame ~= nil then
                        self:setFitPaixin(PaiXing.CARD_TYPE_SAN_DAI_ER)
                        return pokeData
                    end
                else
                    if vNum ~= laiZiNum then
                        -- dump(retPokes)
                        if (#retPokes + #oriNum) >= 3 then
                            for k,v in pairs(oriNum) do
                                table.insert(self._changeNum, {v, dataCloneTmp[retPokes[1]].svrNum})
                                table.insert(retPokes, laiziPokes[k])
                                if #retPokes == 3 then
                                    Game.DDZUtil:clearTableBySeq(retPokes, dataCloneTmp)
                                    local retSame = self:checkSamePokeWithNum_LZ(2, dataCloneTmp)
                                    if retSame ~= nil then
                                        self:setFitPaixin(PaiXing.CARD_TYPE_SAN_DAI_ER)
                                        return pokeData
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return nil
    else
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
    end

    return nil
end

function M:findThreeWithOne(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    -- dump(dataClone)
    if pokesNum < 4 then
        return nil
    end
    local retPokes = {}

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v].svrNum)
    end
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
    if #oriNum >= 3 then
        self:setFitPaixin(PaiXing.CARD_TYPE_SAN_DAI_YI)
        return pokeData
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone)

    for kNum,vNum in pairs(allNums) do
        self:clearLaiZiChange()
        if vNum <= TWO then
            local oriNumClone = table.newclone(oriNum)
            local sames = Game.DDZUtil:findSamePoke(vNum, dataClone)
            if (#sames + #oriNumClone) >= 3 then
                local retNum = #sames
                if retNum >= 3 then
                    for iRet=1,3 do
                        table.insert(retPokes, sames[iRet])
                    end
                    self:setFitPaixin(PaiXing.CARD_TYPE_SAN_DAI_YI)
                    return pokeData
                else
                    for iRet=1,retNum do
                        table.insert(retPokes, sames[iRet])
                    end
                    for i=1,3-retNum do
                        table.insert(retPokes, 0)
                        table.insert(self._changeNum, {oriNumClone[1], vNum*10 + 1})
                        table.remove(oriNumClone, 1)
                    end
                    self:setFitPaixin(PaiXing.CARD_TYPE_SAN_DAI_YI)
                    return pokeData
                end
            end
        end
    end
    return nil
end

function M:countPairNum(inData, laiziNum, needPairNum)
    local retChanges = {}
    local duiziCnt = 0
    local laiziClone = table.newclone(laiziNum)
    local dataClone = table.newclone(inData)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    for i,v in ipairs(allNums) do
        local index = {}
        local retPokes = Game.DDZUtil:findSamePoke(v, dataClone)
        local retNum = #retPokes
        if retNum >= 2 then
            for iRet=1,2 do
                table.insert(index, retPokes[iRet])
            end
            Game.DDZUtil:clearTableBySeq(index, dataClone)
            duiziCnt = duiziCnt + 1
        else
            for iRet=1,retNum do
                table.insert(index, retPokes[iRet])
            end
            for i=1,2-retNum do
                if laiziClone[1] ~= nil then
                    table.insert(retChanges, {laiziClone[1], v*10 + 1})
                    table.remove(laiziClone, 1)
                    Game.DDZUtil:clearTableBySeq(index, dataClone)
                    duiziCnt = duiziCnt + 1
                else
                    break
                end
            end
        end
    end
    local laiziPair = (#laiziClone/2)
    if duiziCnt + laiziPair == needPairNum then
        return true, retChanges
    end
    return false,nil
end

function M:fourWithTwoPair(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum ~= 8 then
        return nil
    end
    local index = {}

    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local laiziPokeNum = #laiziPokes
    local oriNum = {}
    self:clearLaiZiChange()
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v].svrNum)
    end
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone)
    local beginNum, endNum = allNums[#allNums], allNums[1]

    if laiziPokeNum == 4 then
        if laiZiNum > endNum then
            local dataCloneTmp = table.newclone(dataClone)
            local result, changes = self:countPairNum(dataCloneTmp, oriNum, 2)
            if result == true then
                for k,v in pairs(changes) do
                    table.insert(self._changeNum, v)
                end
                return pokeData
            end
        end
    end

    for i,v in ipairs(allNums) do
        self:clearLaiZiChange()
        local oriNumClone = table.newclone(oriNum)
        local retPokes = Game.DDZUtil:findSamePoke(v, dataClone)
        local retNum = #retPokes
        if (retNum + laiziPokeNum) >= 4 then
            local dataCloneTmp = table.newclone(dataClone)
            Game.DDZUtil:clearTableBySeq(retPokes, dataCloneTmp)
            for i=1,4-retNum do
                table.insert(self._changeNum, {oriNumClone[1], v*10+1})
                table.remove(oriNumClone, 1)
            end

            local result, changes = self:countPairNum(dataCloneTmp, oriNumClone, 2)
            if result == true then
                for k,v in pairs(changes) do
                    table.insert(self._changeNum, v)
                end
                return pokeData
            end
        end
    end
    return nil
end

function M:fourWithTwoSingle(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum ~= 6 then
        return nil
    end
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local laiziPokeNum = #laiziPokes
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v].svrNum)
    end
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone)
    local beginNum, endNum = allNums[#allNums], allNums[1]

    self:clearLaiZiChange()

    if laiziPokeNum == 4 then
        if laiZiNum > endNum then
            return pokeData
        end
    end

    for i,v in ipairs(allNums) do
        self:clearLaiZiChange()
        local oriNumClone = table.newclone(oriNum)
        local retPokes = Game.DDZUtil:findSamePoke(v, dataClone)
        local retNum = #retPokes
        if (retNum + laiziPokeNum) >= 4 then
            for i=1,4-retNum do
                table.insert(self._changeNum, {oriNumClone[1], v*10+1})
                table.remove(oriNumClone, 1)
            end
            return pokeData
        end
    end
    return nil
end

function M:findFeiJiWithTwo(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum%5 ~= 0 then
        return nil
    end
    local feijiNum = pokeNum/5
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v].svrNum)
    end
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local beginNum, endNum = allNums[#allNums], allNums[1]
    if endNum > 14 then
        return nil
    end

    local seqList = {}
    local maxStart = 14 - feijiNum + 1

    for i= maxStart, 3, -1 do
        local oriNumClone = table.newclone(oriNum)
        self:clearLaiZiChange()
        seqList = {}
        local index = {}
        local needValue = nil
        for f = 0, feijiNum-1 do
            needValue = i + f
            local retPokes = Game.DDZUtil:findSamePoke(needValue, dataClone)
            local retNum = #retPokes
            if retNum >= 3 then
                table.insert(seqList, needValue)
                for iRet=1,3 do
                    table.insert(index, retPokes[iRet])
                end
            else
                for iRet=1,retNum do
                    table.insert(index, retPokes[iRet])
                end
                local isBreak = false
                for i=1,3-retNum do
                    if #oriNumClone > 0 then
                        table.insert(self._changeNum, {oriNumClone[1], needValue*10 + 1})
                        table.remove(oriNumClone, 1)
                    else
                        isBreak = true
                    end
                end
                if isBreak == true then
                    break
                end
                table.insert(seqList, needValue)
            end
        end
        -- dump(seqList)
        local dataCloneTmp = table.newclone(dataClone)
        local seqListNum = #seqList
        if seqListNum == feijiNum then
            Game.DDZUtil:clearTableBySeq(index, dataCloneTmp)

            local duiziCnt = 0
            local allNums = Game.DDZUtil:buildAllNums(dataCloneTmp, true)
            for i,v in ipairs(allNums) do
                index = {}
                local retPokes = Game.DDZUtil:findSamePoke(v, dataClone)
                local retNum = #retPokes
                if retNum >= 2 then
                    for iRet=1,2 do
                        table.insert(index, retPokes[iRet])
                    end
                    Game.DDZUtil:clearTableBySeq(index, dataCloneTmp)
                    duiziCnt = duiziCnt + 1
                else
                    for iRet=1,retNum do
                        table.insert(index, retPokes[iRet])
                    end

                    for i=1,2-retNum do
                        if #oriNumClone > 0 then
                            table.insert(self._changeNum, {oriNumClone[1], v*10 + 1})
                            table.remove(oriNumClone, 1)
                            Game.DDZUtil:clearTableBySeq(index, dataCloneTmp)
                            duiziCnt = duiziCnt + 1
                        else
                            break
                        end
                    end
                end
            end

            if duiziCnt == feijiNum then
                return pokeData
            end
        end
    end
    return nil
end

function M:findFeiJiWithOne(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum%4 ~= 0 then
        return nil
    end
    self:clearLaiZiChange()
    local feijiNum = pokeNum/4
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v].svrNum)
    end
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local beginNum, endNum = allNums[#allNums], allNums[1]
    if endNum > 14 then
        return nil
    end

    local seqList = {}
    local maxStart = 14 - feijiNum + 1


    for i= maxStart, 3, -1 do
        local oriNumClone = table.newclone(oriNum)
        self:clearLaiZiChange()
        seqList = {}
        local needValue = nil
        for f = 0, feijiNum-1 do
            needValue = i + f

            local retPokes = Game.DDZUtil:findSamePoke(needValue, dataClone)
            local retNum = #retPokes
            if retNum == 3 then
                table.insert(seqList, needValue)
            else
                local isBreak = false
                for i=1,3-retNum do
                    if #oriNumClone > 0 then
                        table.insert(self._changeNum, {oriNumClone[1], needValue*10 + 1})
                        table.remove(oriNumClone, 1)
                    else
                        isBreak = true
                    end
                end
                if isBreak == true then
                    break
                end
                table.insert(seqList, needValue)
            end
        end

        local seqListNum = #seqList
        local seqNum = seqListNum
        local chibangNum = (pokeNum - feijiNum*3)
        if seqNum == chibangNum then
            return pokeData
        end
    end
    return nil
end

function M:findFeiJiPoke(inData)
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum % 3 == 1 then
        return nil
    end

    local retPokes = {}
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v].svrNum)
    end

    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    -- dump(allNums)
    local beginNum, endNum = allNums[1], allNums[#allNums]
    if endNum > 14 then
        return nil
    end
    self:clearLaiZiChange()

    local seqList = {}
    local lastIdx = 1
    local needValue = nil
    for i,v in ipairs(allNums) do
        if seqList[lastIdx] ~= nil then
            local subValue = v - seqList[lastIdx]
            if subValue == 1 then
                needValue = v
                local retPokes = Game.DDZUtil:findSamePoke(needValue, dataClone)
                local retNum = #retPokes
                if retNum ~= 3 then
                    for i=1,3-retNum do
                        if #oriNum > 0 then
                            table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                            table.remove(oriNum, 1)
                        else
                            return nil
                        end
                    end
                end
                table.insert(seqList, needValue)
                lastIdx = lastIdx + 1
            else
                for i=1, subValue do
                    needValue = seqList[lastIdx] + 1
                    if needValue == v then
                        local retPokes = Game.DDZUtil:findSamePoke(needValue, dataClone)
                        local retNum = #retPokes
                        if retNum ~= 3 then
                            for i=1,3-retNum do
                                if #oriNum > 0 then
                                    table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                                    table.remove(oriNum, 1)
                                else
                                    return nil
                                end
                            end
                        end
                        table.insert(seqList, needValue)
                        lastIdx = lastIdx + 1
                    else
                        if #oriNum >=3 then
                            for i=1,3 do
                                table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                                table.remove(oriNum, 1)
                            end
                            table.insert(seqList, needValue)
                            lastIdx = lastIdx + 1
                        else
                            return nil
                        end
                    end
                end
            end

        else
            needValue = v
            local retPokes = Game.DDZUtil:findSamePoke(needValue, dataClone)
            local retNum = #retPokes
            if retNum ~= 3 then
                for i=1,3-retNum do
                    if #oriNum > 0 then
                        table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                        table.remove(oriNum, 1)
                    else
                        return nil
                    end
                end
            end
            table.insert(seqList, needValue)
            lastIdx = 1
        end
    end

    local lzOriNum = #oriNum

    if lzOriNum >= 3 then
        if lzOriNum % 3 == 1 then
            return nil
        end
        while seqList[lastIdx] < 14 and  oriNum[1] ~= nil do
            local needValue = seqList[lastIdx] + 1
            table.insert(seqList, needValue)
            for i=1,3 do
                table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                table.remove(oriNum, 1)
            end
            lastIdx = lastIdx + 1
        end
    end

    lzOriNum = #oriNum
    if lzOriNum >=3 then
        if lzOriNum % 3 == 1 then
            return nil
        end
        needValue = seqList[1] - 1
        while needValue >= 3 and  #oriNum >=3 do
            table.insert(seqList, 1, needValue)
            for i=1,3 do
                table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                table.remove(oriNum, 1)
            end
            needValue = seqList[1] - 1
        end
    end
    -- dump(pokeNum)
    -- dump(seqList)
    local seqListNum = #seqList
    local seqNum = seqListNum*3
    if seqNum == pokeNum then
        return pokeData
    end
    return nil
end

function M:findThreeOrMoreDoublePoke(inData)
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone
    if pokeNum % 2 == 1 then
        return nil
    end

    local retPokes = {}
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v].svrNum)
    end

    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local beginNum, endNum = allNums[#allNums], allNums[1]
    if endNum > 14 then
        return nil
    end
    self:clearLaiZiChange()

    local seqList = {}
    local lastIdx = 1
    local needValue = nil
    for i,v in ipairs(allNums) do
        if seqList[lastIdx] ~= nil then
            local subValue = v - seqList[lastIdx]
            if subValue == 1 then
                needValue = v
                local retPokes = Game.DDZUtil:findSamePoke(needValue, dataClone)
                if #retPokes == 2 then
                    table.insert(seqList, v)
                else
                    if #oriNum > 0 then
                        table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                        table.remove(oriNum, 1)
                        table.insert(seqList, v)
                    else
                        return nil
                    end
                end
                lastIdx = lastIdx + 1
            else
                for i=1, subValue do
                    needValue = seqList[lastIdx] + 1
                    if needValue == v then
                        local retPokes = Game.DDZUtil:findSamePoke(needValue, dataClone)
                        if #retPokes == 2 then
                            table.insert(seqList, needValue)
                        else
                            if #oriNum > 0 then
                                table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                                table.remove(oriNum, 1)
                                table.insert(seqList, needValue)
                            else
                                return nil
                            end
                        end
                        lastIdx = lastIdx + 1
                    else
                        if #oriNum >=2 then
                            table.insert(seqList, needValue)
                            for i=1,2 do
                                table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                                table.remove(oriNum, 1)
                            end
                            lastIdx = lastIdx + 1
                        else
                            return nil
                        end
                    end
                end
            end

        else
            needValue = v
            local retPokes = Game.DDZUtil:findSamePoke(needValue, dataClone)
            if #retPokes == 2 then
                table.insert(seqList, v)
            else
                if #oriNum > 0 then
                    table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                    table.remove(oriNum, 1)
                    table.insert(seqList, v)
                else
                    return nil
                end
            end
            lastIdx = 1
        end
    end

    local lzOriNum = #oriNum

    if lzOriNum >= 2 then
        if lzOriNum % 2 == 1 then
            return nil
        end
        while seqList[lastIdx] < 14 and  oriNum[1] ~= nil do
            local needValue = seqList[lastIdx] + 1
            table.insert(seqList, needValue)
            for i=1,2 do
                table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                table.remove(oriNum, 1)
            end
            lastIdx = lastIdx + 1
        end
    end

    lzOriNum = #oriNum
    if lzOriNum >=2 then
        if lzOriNum % 2 == 1 then
            return nil
        end
        needValue = seqList[1] - 1
        while needValue >= 3 and  #oriNum >=2 do
            table.insert(seqList, 1, needValue)
            for i=1,2 do
                table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                table.remove(oriNum, 1)
            end
            needValue = seqList[1] - 1
        end
    end

    local seqListNum = #seqList
    local seqNum = seqListNum*2
    if seqNum == pokeNum then
        return pokeData
    end
    return nil
end

--@ 获取顺子牌
function M:findShunZi(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local pokeNum = #dataClone
    if pokeNum < 5 then
        return nil
    end

    local retPokes = {}
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v].svrNum)
    end

    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local beginNum, endNum = allNums[#allNums], allNums[1]
    if endNum > 14 then
        return nil
    end
    self:clearLaiZiChange()

    local seqList = {}
    local lastIdx = 1
    local needValue = nil
    for i,v in ipairs(allNums) do
        if seqList[lastIdx] ~= nil then
            local subValue = v - seqList[lastIdx]
            if subValue == 1 then
                table.insert(seqList, v)
                lastIdx = lastIdx + 1
            else
                for i=1, subValue do
                    needValue = seqList[lastIdx] + 1
                    if needValue == v then
                        table.insert(seqList, needValue)
                        lastIdx = lastIdx + 1
                    else
                        if #oriNum > 0 then
                            table.insert(seqList, needValue)
                            table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
                            table.remove(oriNum, 1)
                            lastIdx = lastIdx + 1
                        else
                            return nil
                        end
                    end
                end
            end

        else
            table.insert(seqList, v)
            lastIdx = 1
        end
    end

    local lzOriNum = #oriNum
    if lzOriNum > 0 then
        while seqList[lastIdx] < 14 and  oriNum[1] ~= nil do
            local needValue = seqList[lastIdx] + 1
            table.insert(seqList, needValue)
            table.insert(self._changeNum, {oriNum[1], needValue*10 + 1})
            table.remove(oriNum, 1)
            lastIdx = lastIdx + 1
        end
    end

    lzOriNum = #oriNum
    if lzOriNum > 0 then
        for i=1,lzOriNum do
            local needValue = seqList[1] - 1
            if needValue < 3 then
                return nil
            end
            -- dump(seqList)
            table.insert(seqList, 1, needValue)
            table.insert(self._changeNum, {oriNum[i], needValue*10 + 1})
        end
    end

    if #seqList == pokeNum then
        return pokeData
    end
    return nil
end

function M:findBomb(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone

    if pokesNum == 2 then
        local pokes = self:findTwoJoker(dataClone)
        if pokes ~= nil then
            return pokes
        end
    elseif pokesNum == 4 then
        local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
        local oriNum = {}
        for k,v in pairs(laiziPokes) do
            table.insert(oriNum, dataClone[v].svrNum)
        end
        if #oriNum == 4 then
            return pokeData
        end
        Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
        local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
        for k,v in pairs(allNums) do
            local retPokes = Game.DDZUtil:findSamePoke(v, dataClone)
            if #retPokes + #oriNum == 4 then
                self:clearLaiZiChange()
                while oriNum[1] ~= nil do
                    table.insert(self._changeNum, {oriNum[1], v*10 + 1})
                    table.remove(oriNum, 1)
                end
                return pokeData
            end
        end
    end
    return nil
end

function M:findThree(inData)
    local pokeData = inData
    self:clearLaiZiChange()
    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    if pokesNum < 3 then
        return nil
    end
    local retPokes = {}
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    -- dump(laiziPokes)
    if #laiziPokes > 0 then
        local dxWang = self:selectDXWangPokes(dataClone)
        if #dxWang > 0 then
            return nil
        end
        local oriNum = {}
        for k,v in pairs(laiziPokes) do
            table.insert(oriNum, dataClone[v].svrNum)
        end

        Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
        if #dataClone >= 1 then
            for k,v in pairs(oriNum) do
                table.insert(self._changeNum, {v, dataClone[1].svrNum})
            end
        end
        for k,v in pairs(pokeData) do
            table.insert(retPokes, v)
        end
    else
        local pokes = self:findSamePokeWithNum(3, dataClone)
        if pokes ~= nil then
            for k,v in pairs(pokes) do
                table.insert(retPokes, v)
            end
        else
            return nil
        end
    end


    local retPokeNum = #retPokes
    if retPokeNum == 3 then
        self:setFitPaixin(PaiXing.CARD_TYPE_SAN_ZHANG)
        return retPokes
    end
    return nil
end

function M:findDoublePoke(inData)
    local retPokes = {}
    self:clearLaiZiChange()
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    if #laiziPokes > 0 then
        local dxWang = self:selectDXWangPokes(pokeData)
        if #dxWang > 0 then
            return nil
        end
        local oriCardNum = dataClone[laiziPokes[1]].svrNum
        Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
        if #dataClone == 1 then
            table.insert(self._changeNum, {oriCardNum, dataClone[1].svrNum})
        end

        for k,v in pairs(pokeData) do
            table.insert(retPokes, v)
        end
    else
        local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
        if #allNums == 1 and #dataClone == 2 then
            table.insert(retPokes, 1)
            table.insert(retPokes, 2)
        end
    end
    if #retPokes == 2 then
        return retPokes
    end
    return nil
end

function M:findOnePoke(inData)
    local retPokes = {}
    local pokeData = inData

    self:clearLaiZiChange()

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
        return retPokes
    end
    return nil
end
return M
