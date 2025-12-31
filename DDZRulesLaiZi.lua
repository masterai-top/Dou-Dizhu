-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36

local aiAllStep = {
    [1] = 1,
    [2] = 2,
    [3] = 5,
    [4] = 4,
    [5] = 4,
    [6] = 4,
    [7] = 4,
    [8] = 5,
    [9] = 5,
    [10] = 5,
    [11] = 5,
    [12] = 5,
    [13] = 1,
    [14] = 1,
}

local paixingFunc = {}

local M = class("DDZRulesLaiZi")

function M:ctor()
    self._toSelectPokes = {}
    self._ddzPX_LZ = require_ex("games.ddz.models.DDZPaiXingLaiZi"):new()

    self._ddzPX = require_ex("games.ddz.models.DDZPaiXing"):new()
    self._tgRules = require_ex("games.ddz.models.DDZRulesLaiZiTG"):new()
    self._goLinkRules = require_ex("games.ddz.models.DDZRulesGoLinkLaiZi"):new()
    self._roundType = nil
    self._lastMainPokeNum = nil
    self._mainRoundPokeNum = nil
    self._useBombFunc = nil

    self._autoSelectStep = 1
    self._needFeiJiNum = nil
    self._needShunNum = nil
end

function M:getLastMainNum()
    return self._lastMainPokeNum
end

function M:checkLastMainNumBigRound()
    return self._lastMainPokeNum > self._mainRoundPokeNum
end

function M:getLaiZiChange()
    return self._ddzPX_LZ:getLaiZiChange()
end

function M:clearCheckType()
    self._ddzPX_LZ:clearCheckType()
end

function M:findTwoJoker(inData)
    local retPokes = {}
    local pokeData = inData

    if self._lastMainPokeNum == BIG_JOKER then
        return nil
    end

    -- dump(pokeData)
    for k,data in pairs(pokeData) do
        -- dump(data)
        local num = data.num
        if num == BIG_JOKER then
            table.insert(retPokes, k)
        elseif num == SMALL_JOKER then
            table.insert(retPokes, k)
        end
    end
    -- dump(retPokes)
    if #retPokes == 2 then
        self._lastMainPokeNum = BIG_JOKER
        return retPokes
    end
    return nil
end

function M:noBigPoke()
    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_SHOW_NO_BIG_POKE_EVENT, {isShow = true})
end

function M:findSamePokeWithNum(sameNum, inData)
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)

    for i,v in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(v, dataClone)
        if #sames == sameNum then
            return sames
        end
    end
    return nil
end

function M:fourWithTwoPair(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone

    if pokeNum < 6 then
        return nil
    end

    local fours = self:findFour(dataClone)
    if fours == nil then
        return nil
    end
    Game.DDZUtil:clearTableBySeq(fours, dataClone)

    local findOne = self:findMoreTwoNotMain(dataClone, 4)
    if findOne == nil then
        return nil
    end

    for i,v in ipairs(findOne) do
        table.insert(fours, v)
    end

    return fours
end

function M:fourWithTwoSingle(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone

    if pokeNum < 6 then
        return nil
    end

    local fours = self:findFour(dataClone)
    if fours == nil then
        return nil
    end
    Game.DDZUtil:clearTableBySeq(fours, dataClone)

    local findOne = self:findMoreOneNotMain(dataClone, 2)
    if findOne == nil then
        return nil
    end

    for i,v in ipairs(findOne) do
        table.insert(fours, v)
    end

    return fours
end

function M:findMoreTwoNotMain(inData, moreNum)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v])
    end
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)
    local collect = Game.DDZUtil:makeLaiZiCollectInfo(dataClone)

    for iCo,vCo in ipairs(collect) do
        for iVa,vVa in ipairs(vCo) do
            if iCo == 4 then
                if oriNum[1] ~= nil then
                    local sames = Game.DDZUtil:findSamePoke(vVa, dataClone)
                    table.insert(retPokes, dataClone[sames[1]].index)
                    table.insert(retPokes, oriNum[1].index)
                    table.remove(oriNum, 1)
                    if #retPokes == moreNum then
                        return retPokes
                    end
                end
            else
                local sames = Game.DDZUtil:findSamePoke(vVa, dataClone)
                if iCo == 2 then
                    table.insert(retPokes, dataClone[sames[1]].index)
                    table.insert(retPokes, dataClone[sames[2]].index)
                    if #retPokes == moreNum then
                        return retPokes
                    end
                elseif iCo == 3 then
                    table.insert(retPokes, dataClone[sames[1]].index)
                    table.insert(retPokes, dataClone[sames[2]].index)
                    if #retPokes == moreNum then
                        return retPokes
                    end
                    if oriNum[1] ~= nil then
                        table.insert(retPokes, dataClone[sames[3]].index)
                        table.insert(retPokes, oriNum[1].index)
                        table.remove(oriNum, 1)
                        if #retPokes == moreNum then
                            return retPokes
                        end
                    end
                elseif iCo == 4 then
                    table.insert(retPokes, dataClone[sames[1]].index)
                    table.insert(retPokes, dataClone[sames[2]].index)
                    if #retPokes == moreNum then
                        return retPokes
                    end

                    table.insert(retPokes, dataClone[sames[3]].index)
                    table.insert(retPokes, dataClone[sames[4]].index)
                    if #retPokes == moreNum then
                        return retPokes
                    end
                end
            end
        end
    end
    for k,v in pairs(oriNum) do
        table.insert(retPokes, v.index)
        if #retPokes == moreNum then
            return retPokes
        end
    end
    return nil
end

function M:findFeiJiWithTwo(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)

    local feijiNum = self._needFeiJiNum
    -- dump(feijiNum)

    local feijis = self:findFeiJiPoke(dataClone)
    if feijis == nil then
        return nil
    end
    -- dump(feijis)
    Game.DDZUtil:clearTableBySeq(feijis, dataClone)

    local findOne = self:findMoreTwoNotMain(dataClone, feijiNum*2)
    -- dump(findOne)
    if findOne == nil then
        return nil
    end

    for i,v in ipairs(findOne) do
        table.insert(feijis, v)
    end
    return feijis
end

function M:findFeiJiWithOne(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone

    local feijiNum = self._needFeiJiNum
    -- dump(feijiNum)

    local feijis = self:findFeiJiPoke(dataClone)
    if feijis == nil then
        return nil
    end
    Game.DDZUtil:clearTableBySeq(feijis, dataClone)

    local findOne = self:findMoreOneNotMain(dataClone, feijiNum)

    if findOne == nil then
        return nil
    end

    for i,v in ipairs(findOne) do
        table.insert(feijis, v)
    end
    return feijis
end

function M:checkNeedValue(needValue)
    local isOk = true
    local stepRuleFound = false
    if self._autoSelectStep == 1 then
        local checkOk = Game.DDZUtil:checkSinglePoke(needValue)
        if checkOk == false then
            isOk = false
            return isOk, stepRuleFound, true
        else
            stepRuleFound = true
        end
    elseif self._autoSelectStep == 2 then
        local checkOne = Game.DDZUtil:checkSinglePoke(needValue)
        local checkDouble = Game.DDZUtil:checkDoublePoke(needValue)
        local checkOk = (checkOne or checkDouble)

        if checkOk == false then
            isOk = false
            return isOk, stepRuleFound, true
        end
        if checkDouble == true then
            stepRuleFound = true
        end
    elseif self._autoSelectStep == 3 then
        local checkOne = Game.DDZUtil:checkSinglePoke(needValue)
        local checkDouble = Game.DDZUtil:checkDoublePoke(needValue)
        local checkThree = Game.DDZUtil:checkThreePoke(needValue)
        local checkOk = (checkOne or checkDouble or checkThree)
        if checkOk == false then
            isOk = false
            return isOk, stepRuleFound, true
        end
        if checkThree == true then
            stepRuleFound = true
        end
    elseif self._autoSelectStep == 4 then
        local checkOne = Game.DDZUtil:checkSinglePoke(needValue)
        local checkDouble = Game.DDZUtil:checkDoublePoke(needValue)
        local checkThree = Game.DDZUtil:checkThreePoke(needValue)
        local checkFour = Game.DDZUtil:checkFourPoke(needValue)
        local checkOk = (checkOne or checkDouble or checkThree or checkFour)
        if checkOk == false then
            isOk = false
            return isOk, stepRuleFound, true
        end

        if checkFour == true then
            stepRuleFound = true
        end
    end
    return isOk, stepRuleFound, false
end

function M:checkToNeedValue(needValue, is_double)
    if self._autoSelectStep == 1 then
        local checkOk = Game.DDZUtil:checkSinglePoke(needValue)
        if checkOk == false or is_double then
            return false, false, false
        else
            return true, true, false
        end
    elseif self._autoSelectStep == 2 then
        local checkOne = Game.DDZUtil:checkSinglePoke(needValue)
        local checkDouble = Game.DDZUtil:checkDoublePoke(needValue)
        local checkOk = ((checkOne and not is_double) or checkDouble)

        if checkOk == false then
            return false, false, false

        elseif checkDouble then
            return true, true, false
        else
            return true, false, false
        end
    elseif self._autoSelectStep == 3 then
        local checkOne = Game.DDZUtil:checkSinglePoke(needValue)
        local checkDouble = Game.DDZUtil:checkDoublePoke(needValue)
        local checkThree = Game.DDZUtil:checkThreePoke(needValue)
        local checkOk = ((checkOne and not is_double) or checkDouble or checkThree)
        if checkOk == false then
            return false, false, false

        elseif checkThree then
            return true, true, false
        else
            return true, false, false
        end
    elseif self._autoSelectStep == 4 then
        local checkOne = Game.DDZUtil:checkSinglePoke(needValue)
        local checkDouble = Game.DDZUtil:checkDoublePoke(needValue)
        local checkThree = Game.DDZUtil:checkThreePoke(needValue)
        local checkFour = Game.DDZUtil:checkFourPoke(needValue)
        local checkOk = ((checkOne and not is_double) or checkDouble or checkThree or checkFour)
        if checkOk == false then
            return false, false, false

        elseif checkFour then
            return true, true, false
        else
            return true, false, false
        end
    elseif self._autoSelectStep == 5 then
        local checkOne = Game.DDZUtil:checkSinglePoke(needValue)
        local checkDouble = Game.DDZUtil:checkDoublePoke(needValue)
        local checkThree = Game.DDZUtil:checkThreePoke(needValue)
        local checkFour = Game.DDZUtil:checkFourPoke(needValue)
        local checkOk = ((checkOne and not is_double) or checkDouble or checkThree or checkFour)
        if checkOk == false then
            return false, true, true
        else
            return true, true, false
        end
    end
    return false, false
end

--@ 获取顺子牌
function M:findShunZi(inData)
    local lastPokes = Game.DDZPlayDB:getRoundPokes()
    local shunNum = self._needShunNum
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local pokeNum = #dataClone
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local allNumsMap = Game.DDZUtil:makeNumMap(allNums)

    local gamesAllNums = {}
    for i=self._lastMainPokeNum + 1, 14 do
        table.insert(gamesAllNums, i)
    end

    local numCnt = #gamesAllNums
    local maxStartNum = 15 - shunNum

    if numCnt < shunNum then
        return nil
    end
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v])
    end
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    local retPokes = {}
    for i,v in ipairs(gamesAllNums) do
        -- 开始顺子头
        retPokes = {}
        local oriNumClone = table.newclone(oriNum)
        self._ddzPX_LZ:clearLaiZiChange()
        
        local isOk = true
        local needValue = v
        if needValue > maxStartNum then
            return nil
        end
        -- 开始顺子
        for j=i,numCnt do
            if needValue >= TWO 
                or (not allNumsMap[needValue] and #oriNumClone <= 0) 
                or (needValue == laiZiNum and (#oriNumClone <= 0)) then
                break
            end
            local isOk, stepRuleFound, isLaiZi = self:checkToNeedValue(needValue, false)
            if not isOk and not isLaiZi then
                break
            end
            if allNumsMap[needValue] == nil then
                local laiziOne = oriNumClone[1]
                local change = Game.DDZUtil:makeLaiZiChange(laiziOne.svrNum, needValue)
                self._ddzPX_LZ:insertLaiZiChange(change)

                table.insert(retPokes, oriNumClone[1].index)
                table.remove(oriNumClone, 1)

            elseif needValue == laiZiNum then
                table.insert(retPokes, oriNumClone[1].index)
                table.remove(oriNumClone, 1)
            else
                local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
                table.insert(retPokes, sames[1])
            end
            if #retPokes == shunNum then
                if stepRuleFound == false then
                    -- break
                end
                self._lastMainPokeNum = needValue-#retPokes+1
                return retPokes
            end
            needValue = needValue + 1
        end
    end
    return nil
end

function M:findThreeOrMoreDoublePoke(inData)
    local lastPokes = Game.DDZPlayDB:getRoundPokes()
    local shunNum = self._needShunNum
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local pokeNum = #dataClone
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local allNumsMap = Game.DDZUtil:makeNumMap(allNums)

    local gamesAllNums = {}
    for i=self._lastMainPokeNum + 1, 14 do
        table.insert(gamesAllNums, i)
    end

    local numCnt = #gamesAllNums
    local maxStartNum = 15 - shunNum

    if numCnt < shunNum then
        return nil
    end

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v])
    end
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    local retPokes = {}
    for i,v in ipairs(gamesAllNums) do
        retPokes = {}
        local oriNumClone = table.newclone(oriNum)
        self._ddzPX_LZ:clearLaiZiChange()
        
        local needValue = v
        if needValue > maxStartNum then
            return nil
        end
        for j=i,numCnt do
            if needValue >= TWO then
                break
            end
            local lzCnts = #oriNumClone
            local needValSames = Game.DDZUtil:findSamePoke(needValue, dataClone)
            local needValCnts = #needValSames

            if needValue == laiZiNum then
                lzCnts = 0
            end
            if (needValCnts + lzCnts) < 2 then
                break
            end
            local isOk, stepRuleFound, isLaiZi = self:checkToNeedValue(needValue, true)
            if not isOk and not isLaiZi then
                break
            end      
            if isLaiZi then
                if needValCnts >= 2 then
                    break
                end
                table.insert(retPokes, needValSames[1])
                for i=1,(2-needValCnts) do
                    local laiziOne = oriNumClone[1]
                    local change = Game.DDZUtil:makeLaiZiChange(laiziOne.svrNum, needValue)
                    self._ddzPX_LZ:insertLaiZiChange(change)
                    table.insert(retPokes, laiziOne.index)
                    table.remove(oriNumClone, 1)
                end               
            elseif needValue == laiZiNum then
                for i=1,2 do
                    table.insert(retPokes, oriNumClone[1].index)
                    table.remove(oriNumClone, 1)
                end
            else
                local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
                if needValCnts >= 2 then
                    for i=1,2 do
                        table.insert(retPokes, needValSames[i])
                    end
                elseif needValCnts == 1 then
                    table.insert(retPokes, needValSames[1])
                    local laiziOne = oriNumClone[1]
                    local change = Game.DDZUtil:makeLaiZiChange(laiziOne.svrNum, needValue)
                    self._ddzPX_LZ:insertLaiZiChange(change)
                    table.insert(retPokes, laiziOne.index)
                    table.remove(oriNumClone, 1)
                end
            end

            if #retPokes == shunNum*2 then
                if stepRuleFound == false then
                    break
                end
                self._lastMainPokeNum = needValue-shunNum+1
                return retPokes
            end
            needValue = needValue + 1
        end
    end
    return nil
end

function M:findFeiJiPoke(inData)
    local shunNum = self._needFeiJiNum
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local pokeNum = #dataClone
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local allNumsMap = Game.DDZUtil:makeNumMap(allNums)

    local gamesAllNums = {}
    for i=self._lastMainPokeNum + 1, 14 do
        table.insert(gamesAllNums, i)
    end

    local numCnt = #gamesAllNums
    local maxStartNum = 15 - shunNum

    if numCnt < shunNum then
        return nil
    end

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v])
    end
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    local retPokes = {}
    for i,v in ipairs(gamesAllNums) do
        retPokes = {}
        local oriNumClone = table.newclone(oriNum)
        self._ddzPX_LZ:clearLaiZiChange()
        
        local isOk = true
        local stepRuleFound = false
        local needValue = v
        if needValue > maxStartNum then
            return nil
        end
        for j=i,numCnt do
            if needValue >= TWO then
                break
            end
            local needValSames = Game.DDZUtil:findSamePoke(needValue, dataClone)
            local needValCnts = #needValSames
            local lzCnts = #oriNumClone
            if needValue == laiZiNum then
                lzCnts = 0
            end
            if (needValCnts + lzCnts) < 3 then
                break
            end
            local isOk, stepRuleFound, isLaiZi = self:checkToNeedValue(needValue, true)
            if not isOk and not isLaiZi then
                break
            end
            if isLaiZi then
                if needValCnts >= 3 then
                    break
                else
                    for i=1,needValCnts do
                        table.insert(retPokes, needValSames[i])
                    end
                    for i=1,3-needValCnts do
                        local laiziOne = oriNumClone[1]
                        local change = Game.DDZUtil:makeLaiZiChange(laiziOne.svrNum, needValue)
                        self._ddzPX_LZ:insertLaiZiChange(change)
                        table.insert(retPokes, laiziOne.index)
                        table.remove(oriNumClone, 1)
                    end
                end
            elseif needValue == laiZiNum then
                for i=1,3 do
                    if oriNumClone[1] then
                        table.insert(retPokes, oriNumClone[1].index)
                        table.remove(oriNumClone, 1)
                    end
                end
            else
                local sames = Game.DDZUtil:findSamePoke(needValue, dataClone)
                if needValCnts >= 3 then
                    for i=1,3 do
                        table.insert(retPokes, needValSames[i])
                    end
                else
                    break
                end
            end
            if #retPokes == shunNum*3 then
                if stepRuleFound == false then
                    break
                end
                self._lastMainPokeNum = needValue-shunNum+1
                return retPokes
            end
            needValue = needValue + 1
        end
    end
    return nil
end

function M:findFour(inData)
    local pokeData = inData
    local pokesNum = #pokeData
    if pokesNum < 4 then
        return nil
    end
    local retPokes = {}
    self._ddzPX_LZ:clearLaiZiChange()

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(pokeData)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, pokeData[v])
    end
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    local lastNum = nil
    local allNums = Game.DDZUtil:buildAllNums(pokeData, true)
    for i,v in ipairs(allNums) do
        local needValue = v
        if needValue > TWO then
            break
        end
        local checkNum = v
        if needValue == laiZiNum then
            checkNum = 18
        end
        if checkNum > self._lastMainPokeNum and (needValue <= TWO) then
            local sames = Game.DDZUtil:findSamePoke(needValue, pokeData)
            local sameNum = #sames
            if laiZiNum == needValue then
                if sameNum == 4 and #retPokes ~= 4 then
                    retPokes = {}
                    for kSame,vSame in pairs(sames) do
                        table.insert(retPokes, vSame)
                    end
                    lastNum = 18
                end
            else
                if sameNum == 4 then
                    retPokes = {}
                    for kSame,vSame in pairs(sames) do
                        table.insert(retPokes, vSame)
                    end
                    lastNum = needValue
                    break

                elseif (sameNum + #oriNum) >= 4 and #retPokes ~= 4 then
                    retPokes = {}
                    for iRet=1,sameNum do
                        table.insert(retPokes, sames[iRet])
                    end
                    for i=1,4-sameNum do
                        local change = Game.DDZUtil:makeLaiZiChange(oriNum[1].svrNum, needValue)
                        self._ddzPX_LZ:insertLaiZiChange(change)
                        table.insert(retPokes, oriNum[1].index)
                        table.remove(oriNum, 1)
                    end
                    lastNum = needValue                    
                end
            end
        end
    end
    if lastNum and #retPokes == 4 then
        self._lastMainPokeNum = lastNum
        return retPokes
    end
    return nil
end

function M:findThree(inData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    self._ddzPX_LZ:clearLaiZiChange()

    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v])
    end

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local okNum = nil
    for i,v in ipairs(allNums) do
        local thisNum = v
        local checkOk = false
        retPokes = {}
        if thisNum > self._lastMainPokeNum and (thisNum <= TWO) then
            if self._autoSelectStep == 1 then
                checkOk = Game.DDZUtil:checkThreePoke(thisNum)
                if thisNum == laiZiNum then
                    checkOk = false
                end

            elseif self._autoSelectStep == 2 then
                if #oriNum < 1 then
                    break
                end
                checkOk = Game.DDZUtil:checkDoublePoke(thisNum)
                if thisNum == laiZiNum and checkOk == true then
                    checkOk = false
                end                

            elseif self._autoSelectStep == 3 then
                if #oriNum < 2 then
                    break
                end
                checkOk = Game.DDZUtil:checkSinglePoke(thisNum)
                if thisNum == laiZiNum and checkOk == true then
                    checkOk = false
                end
                
            elseif self._autoSelectStep == 4 then
                checkOk = Game.DDZUtil:checkFourPoke(thisNum)   
                if thisNum == laiZiNum then
                    checkOk = false
                end         
            end
            if checkOk == true then
                local sames = Game.DDZUtil:findSamePoke(thisNum, dataClone)
                local needAddNum = 3 - #sames
                if needAddNum > 0 then
                    for i=1,needAddNum do
                        local laiziOne = oriNum[i]
                        table.insert(sames, laiziOne.index)
                        local change = Game.DDZUtil:makeLaiZiChange(laiziOne.svrNum, thisNum)
                        self._ddzPX_LZ:insertLaiZiChange(change)
                    end
                end

                for i=1,3 do
                    table.insert(retPokes, sames[i])
                end
                okNum = thisNum
                break
            end
        end
    end
    if #retPokes == 3 then
        self._lastMainPokeNum = okNum
        return retPokes
    end
    -- 纯癞子
    if self._autoSelectStep == 4 and laiZiNum > self._lastMainPokeNum and #oriNum >= 3 then
        for i=1,3 do
            local laiziOne = oriNum[i]
            table.insert(retPokes, laiziOne.index)
        end
        self._autoSelectStep = 5
        return retPokes
    end
    return nil
end

function M:checkShunZiPokeForLZ(pokeNum)
    local pokeData = Game.DDZPlayDB:getPokesData()

    local dataClone = table.newclone(pokeData)

    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v])
    end

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)

    local numCnt = #allNums
    if numCnt < 5 then
        return false
    end

    for i,v in ipairs(allNums) do
        local oriNumClone = table.newclone(oriNum)
        local seqList = {}
        local hasPoke = false
        local needValue = v
        for j=i,numCnt do
            if needValue >= TWO then
                break
            end
            if allNums[j] == needValue or #oriNumClone > 0 then
                if needValue == pokeNum then
                    hasPoke = true
                end
                table.insert(seqList, needValue)
                if needValue == laiZiNum or allNums[j] ~= needValue then
                    table.remove(oriNumClone, 1)
                end

                if #seqList >= 5 and hasPoke == true then
                    return true
                end
                needValue = needValue + 1
            else
                break
            end
        end
    end
    return false
end

function M:findOnePoke(inData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    local selNums = {}

    for i,v in ipairs(allNums) do
        local thisNum = v
        local compNum = v
        if thisNum == laiZiNum then
            compNum = 18
        end
        if compNum > self._lastMainPokeNum then
            if self._autoSelectStep == 1 then
                local checkOne = Game.DDZUtil:checkSinglePoke(thisNum)
                local checkSZ = false
                -- local checkSZ = self:checkShunZiPokeForLZ(thisNum)
                local checkOk = checkOne and (not checkSZ) and thisNum ~= laiZiNum
                if checkOk == true then
                    table.insert(selNums, thisNum)
                    break
                end
            elseif self._autoSelectStep == 2 then
                local checkTwo = Game.DDZUtil:checkDoublePoke(thisNum)
                local checkSZ = false
                -- local checkSZ = self:checkShunZiPokeForLZ(thisNum)
                local checkOk = checkTwo and (not checkSZ) and thisNum ~= laiZiNum
                if checkOk == true then
                    table.insert(selNums, thisNum)
                    break
                end
            elseif self._autoSelectStep == 3 then
                local checkThree = Game.DDZUtil:checkThreePoke(thisNum)
                local checkSZ = false
                -- local checkSZ = self:checkShunZiPokeForLZ(thisNum)
                local checkOk = checkThree and (not checkSZ) and thisNum ~= laiZiNum
                if checkOk == true then
                    table.insert(selNums, thisNum)
                    break
                end
            elseif self._autoSelectStep == 4 then
                -- local checkSZ = self:checkShunZiPokeForLZ(thisNum)
                local checkSZ = false
                if not checkSZ and thisNum > self._lastMainPokeNum then
                    table.insert(selNums, thisNum)
                    break
                end
                if thisNum == laiZiNum and thisNum > self._lastMainPokeNum then
                    selNums = {}
                    table.insert(selNums, thisNum)
                end
            elseif self._autoSelectStep == 5 then
                local checkOk = Game.DDZUtil:checkFourPoke(thisNum)
                if checkOk == true and thisNum ~= laiZiNum then
                    selNums = {}
                    table.insert(selNums, thisNum)
                    break
                end
            end
        end
    end
    if #selNums == 1 then
        local samePokes = Game.DDZUtil:findSamePoke(selNums[1], dataClone)

        if selNums[1] ~= laiZiNum then
            self._lastMainPokeNum = selNums[1]
        else
            self._lastMainPokeNum = 18
        end
        table.insert(retPokes, samePokes[1])
        return retPokes
    end

    return nil
end

function M:findMoreOneNotMain(inData, moreNum)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = Game.DDZUtil:makeLaiZiCollectInfo(dataClone)

    for iCo,vCo in ipairs(collect) do
        for iVa,vVa in ipairs(vCo) do
            local sames = Game.DDZUtil:findSamePoke(vVa, dataClone)
            for i,v in ipairs(sames) do
                table.insert(retPokes, dataClone[v].index)
                if #retPokes == moreNum then
                    return retPokes
                end
            end
        end
    end
    return nil
end

function M:findOneNotMain(inData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = {-1, -1, -1, -1, -1}

    local allNums = Game.DDZUtil:buildAllNums(dataClone)
    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()

    for i,v in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(v, dataClone)
        if sames then
            local index = dataClone[sames[1]].index
            if v == laiZiNum then
                collect[4] = index
            elseif #sames == 1 then
                collect[1] = index
            elseif #sames == 2 then
                collect[2] = index
            elseif #sames == 3 then
                collect[3] = index
            elseif #sames == 4 then
                collect[5] = index
            end
        end
    end

    for i,v in ipairs(collect) do
        if v ~= -1 then
            table.insert(retPokes, v)
            return retPokes
        end
    end
    return nil
end

function M:findOnePairPoke(inData)
    local retPokes = {}
    local pokeData = inData

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(pokeData)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, pokeData[v].svrNum)
    end
    local allNums = Game.DDZUtil:buildAllNums(pokeData, true)
    for i,v in ipairs(allNums) do
        local needValue = v
        local sames = Game.DDZUtil:findSamePoke(needValue, pokeData)
        if #sames >= 2 then
            for i=1,2 do
                table.insert(retPokes, sames[i])
            end
            return retPokes
        else
            local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
            if #laiziPokes > 1 and pokeData[sames[1]].num ~= laiZiNum then
                table.insert(retPokes, sames[1])
                table.insert(retPokes, laiziPokes[1])
                self._ddzPX_LZ:insertLaiZiChange({oriNum[1], pokeData[sames[1]].svrNum})
                return retPokes
            end
        end
    end

    return nil
end

function M:findDoublePoke(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    self._ddzPX_LZ:clearLaiZiChange()

    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v])
    end
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local okNum = nil
    for i,v in ipairs(allNums) do
        local thisNum = v

        if thisNum > self._lastMainPokeNum and (thisNum <= TWO) then
            if self._autoSelectStep == 1 then
                local checkOk = Game.DDZUtil:checkDoublePoke(thisNum)
                if checkOk and thisNum ~= laiZiNum then
                    okNum = thisNum
                    break
                end

            elseif self._autoSelectStep == 2 then
                local checkOk = Game.DDZUtil:checkThreePoke(thisNum)
                if checkOk and thisNum ~= laiZiNum then
                    okNum = thisNum
                    break
                end

            elseif self._autoSelectStep == 3 then
                if #oriNum == 0 then
                    break
                end
                local checkOk = Game.DDZUtil:checkSinglePoke(thisNum)
                if thisNum == laiZiNum and checkOk == true then
                    checkOk = false
                end
                if checkOk then
                    okNum = thisNum
                    break
                end
            elseif self._autoSelectStep == 4 then
                local checkOk = Game.DDZUtil:checkFourPoke(thisNum)
                if checkOk and thisNum ~= laiZiNum then
                    okNum = thisNum
                    break
                end
            end
        end
    end
    local retPokes = {}
    if okNum then
        local sames = Game.DDZUtil:findSamePoke(okNum, dataClone)
        if #sames == 1 then
            local laiziOne = oriNum[1]
            table.insert(sames, laiziOne.index)
            local change = Game.DDZUtil:makeLaiZiChange(laiziOne.svrNum, okNum)
            self._ddzPX_LZ:insertLaiZiChange(change)
        end
        for i=1,2 do
            table.insert(retPokes, sames[i])
        end
    end
    if #retPokes == 2 then
        self._lastMainPokeNum = okNum
        return retPokes
    end
    -- 纯癞子
    if self._autoSelectStep == 4 and laiZiNum > self._lastMainPokeNum and #oriNum >= 2 then
        for i=1,2 do
            local laiziOne = oriNum[i]
            table.insert(retPokes, laiziOne.index)
        end
        self._autoSelectStep = 5
        return retPokes
    end
    return nil
end

function M:findOnePairPokeNotMain(inData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(dataClone)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, dataClone[v])
    end
    Game.DDZUtil:clearTableBySeq(laiziPokes, dataClone)

    local allNums = Game.DDZUtil:buildAllNums(dataClone)
    local collect = {-1, -1, -1, -1, -1}
    for i,v in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(v, dataClone)

        if v == laiZiNum then
            if #sames >= 2 then
                collect[5] = v
            end

        elseif #sames == 1 then
            collect[4] = v

        elseif #sames == 2 then
            collect[1] = v

        elseif #sames == 3 then
            collect[2] = v

        elseif #sames == 4 then
            collect[3] = v
        end
    end

    for i,v in ipairs(collect) do
        if v ~= -1 then
            local sames = Game.DDZUtil:findSamePoke(v, dataClone)
            if i == 4 then
                if #oriNum > 0 then
                    table.insert(retPokes, dataClone[sames[1]].index)
                    local laiziOne = oriNum[1]
                    table.insert(retPokes, laiziOne.index)
                    local change = Game.DDZUtil:makeLaiZiChange(laiziOne.svrNum, v)
                    self._ddzPX_LZ:insertLaiZiChange(change)
                    return retPokes
                end
            else
                for iSame=1,2 do
                    table.insert(retPokes, dataClone[sames[iSame]].index)
                end
                return retPokes
            end
        end
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
    self._ddzPX_LZ:clearLaiZiChange()
    local retPokes = {}

    local findThree = self:findThree(dataClone)
    if findThree == nil then
        return nil
    end

    Game.DDZUtil:clearTableBySeq(findThree, dataClone)
    local findOne = self:findOnePairPokeNotMain(dataClone)

    if findOne == nil then
        return nil
    end

    for i,v in ipairs(findThree) do
        table.insert(retPokes, v)
    end

    for i,v in ipairs(findOne) do
        table.insert(retPokes, v)
    end
    return retPokes
end

function M:findThreeWithOne(inData)
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokesNum = #dataClone
    if pokesNum < 4 then
        return nil
    end
    self._ddzPX_LZ:clearLaiZiChange()
    local retPokes = {}
    local findThree = self:findThree(dataClone)
    if findThree == nil then
        return nil
    end
    Game.DDZUtil:clearTableBySeq(findThree, dataClone)
    local findOne = self:findOneNotMain(dataClone)
    if findOne == nil then
        return nil
    end

    for i,v in ipairs(findThree) do
        table.insert(retPokes, v)
    end

    for i,v in ipairs(findOne) do
        table.insert(retPokes, v)
    end
    -- dump(retPokes)
    return retPokes
end

function M:findBomb(inData)
    local retPokes = {}
    local pokeData = nil
    if inData ~= nil then
        pokeData = inData
    end
    local pokesNum = #pokeData
    if pokesNum < 4 then
        local pokes = self:findTwoJoker(pokeData)
        if pokes ~= nil then
            if #pokes == 2 then
                return pokes
            end
        end
    else
        local isRoundLz = Game.DDZPlayDB:isRoundHasLZ()
        local pokeType = self._roundType
        local pokes = nil
        if pokeType == PaiXing.CARD_TYPE_ZHA_DAN then
            for i = self._autoSelectStep, aiAllStep[pokeType] do
                pokes = self:findBombFour(pokeData, i, isRoundLz)
                if pokes ~= nil then
                    break
                end
            end
        else
            pokes = self:findFour(pokeData)
        end

        if pokes ~= nil then
            for k,v in pairs(pokes) do
                table.insert(retPokes, v)
            end
        end

        if #retPokes == 4 then
            return retPokes
        end
        pokes = self:findTwoJoker(pokeData)
        if pokes ~= nil then
            if #pokes == 2 then
                return pokes
            end
        end
    end
    return nil
end

function M:findBombFour(inData, step, isLZBomb)
    local pokeData = inData
    local pokesNum = #pokeData
    if pokesNum < 4 then
        return nil
    end
    local retPokes = {}

    self._ddzPX_LZ:clearLaiZiChange()

    local laiziPokes = Game.DDZUtil:selectLaiZiPokes(pokeData)
    local oriNum = {}
    for k,v in pairs(laiziPokes) do
        table.insert(oriNum, pokeData[v])
    end

    local laiZiNum = Game.DDZPlayDB:getLaiZiNum()
    local allNums = Game.DDZUtil:buildAllNums(pokeData, true)

    for i,v in ipairs(allNums) do
        local needValue = v
        if needValue > TWO then
            break
        end
        local check = false
        if step == 1 then
            if isLZBomb == true then
                check = (needValue > self._lastMainPokeNum)
            end
        elseif step == 2 then
            if isLZBomb == true then
                if self._mainRoundPokeNum ~= self._lastMainPokeNum then
                    check = (needValue > self._lastMainPokeNum)
                else
                    check = true
                end
            else
                check = (needValue > self._lastMainPokeNum)
            end
        else
            assert(false)
        end
        if check then
            local sames = Game.DDZUtil:findSamePoke(needValue, pokeData)
            local sameNum = #sames
            if sameNum == 4 then
                if step == 2 then
                    for kSame,vSame in pairs(sames) do
                        table.insert(retPokes, vSame)
                    end
                    self._lastMainPokeNum = needValue
                    return retPokes
                end
            else
                if step == 1 then
                    if laiZiNum ~= needValue then
                        if (sameNum + #oriNum) >= 4 then
                            for iRet=1,sameNum do
                                table.insert(retPokes, sames[iRet])
                            end
                            for i=1,4-sameNum do
                                local change = Game.DDZUtil:makeLaiZiChange(oriNum[1].svrNum, needValue)
                                self._ddzPX_LZ:insertLaiZiChange(change)
                                table.insert(retPokes, oriNum[1].index)
                                table.remove(oriNum, 1)
                                if #retPokes == 4 then
                                    self._lastMainPokeNum = needValue
                                    return retPokes
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

function M:findBombStep(inData)
    local retPokes = {}
    local pokeData = inData
    local pokesNum = #pokeData
    if pokesNum < 4 then
        if self._autoSelectStep == 2 then
            local pokes = self:findTwoJoker(pokeData)
            if pokes ~= nil then
                if #pokes == 2 then
                    return pokes
                end
            end
        end
    else
        local isRoundLz = Game.DDZPlayDB:isRoundHasLZ()

        local pokes = self:findBombFour(pokeData, self._autoSelectStep, isRoundLz)
        if pokes ~= nil then
            for k,v in pairs(pokes) do
                table.insert(retPokes, v)
            end
        end

        if #retPokes == 4 then
            return retPokes
        end
        if self._autoSelectStep == 2 then
            pokes = self:findTwoJoker(pokeData)
            if pokes ~= nil then
                if #pokes == 2 then
                    return pokes
                end
            end
        end
    end
    return nil
end

function M:getRoundPokeType()
    local lastPokes = Game.DDZPlayDB:getRoundPokes()
    if lastPokes == nil then
        return
    end
    local lastdata = Game.DDZPlayCom:converSvrPokeToClient(lastPokes)
    self._ddzPX:clearCheckType()
    self:selectedPokeJuge(lastdata, self._ddzPX)
    local type = self._ddzPX:getCheckType()
    -- dump(type)
    return type
end

function M:autoSelectPoke_SimpleAi(pokeType)
    local pokes = nil
    local outSelPokes = nil

    if self._useBombFunc ~= nil then
        pokes = self._useBombFunc(self, self._toSelectPokes)
        if pokes == nil then
            self._useBombFunc = nil
            self:rebackToFind()
            self._autoSelectStep = 1
        end
    end

    if pokes == nil then
        local func = paixingFunc[pokeType]
        for i=self._autoSelectStep, aiAllStep[pokeType] do
            pokes, outSelPokes = func(self, self._toSelectPokes)
            if pokes ~= nil then
                break
            else
                self:rebackToFind()
                self._autoSelectStep = self._autoSelectStep + 1
            end
        end

        if pokes == nil and (self._roundType == PaiXing.CARD_TYPE_ZHA_DAN) then
            self:rebackToFind()
            self._autoSelectStep = 1
            for i=self._autoSelectStep, aiAllStep[pokeType] do
                pokes, outSelPokes  = func(self, self._toSelectPokes)
                if pokes ~= nil then
                    break
                else
                    self:rebackToFind()
                    self._autoSelectStep = self._autoSelectStep + 1
                end
            end
        end

        if pokes == nil and (self._roundType ~= PaiXing.CARD_TYPE_ZHA_DAN) then
            local shouldReback = self:rebackToFind(true)
            pokes = self:findBomb(self._toSelectPokes)

            if pokes == nil then
                self:rebackToFind()
                self._autoSelectStep = 1
                for i=self._autoSelectStep, aiAllStep[pokeType] do
                    pokes, outSelPokes  = func(self, self._toSelectPokes)
                    if pokes ~= nil then
                        break
                    else
                        self:rebackToFind()
                        self._autoSelectStep = self._autoSelectStep + 1
                    end
                end
            else
                self._useBombFunc = self.findBomb
            end
        end
    end

    if pokes ~= nil then
        Game.DDZPlayDB:setSelectedPoke(pokes)
        for k,v in pairs(pokes) do
            Game.DDZPlayCom:onPokeSelected(v)
        end
    else
        self:noBigPoke()
        return false
    end
    return true
end

function M:autoSelectPoke()
    self._ddzPX_LZ:clearCheckType()
    local nowRoundState = Game.DDZPlayDB:getRoundState()
    if nowRoundState == 1 then
        local pokeType = self._roundType
        Log(LOG.TAG.DDZ, LOG.LV.INFO, "=====laizi autoSelectPoke pokeType is: " .. tostring(pokeType))
        if pokeType == nil or PaiXing.CARD_TYPE_WANG_ZHA == pokeType then
            self:noBigPoke()
            return false
        end
        return self:autoSelectPoke_SimpleAi(pokeType)
    else
        local setSelPoke = {}
        local pokes, lzChanges = self._tgRules:myTurnGoPoke(Game.DDZPlayDB:getPokesData())
        if pokes ~= nil then
            for k,v in pairs(pokes) do
                Game.DDZPlayCom:onPokeSelected(v)
                table.insert(setSelPoke, v)
            end
        end

        if lzChanges ~= nil then
            for i,v in ipairs(lzChanges) do
                self._ddzPX_LZ:insertLaiZiChange(v)
            end
        end

        Game.DDZPlayDB:setSelectedPoke(setSelPoke)
    end
    return true
end

-- 玩家首次出牌智能选中
function M:autoFulfillSelectPoke(oldSelPoke)
    local pokes_data = Game.DDZPlayDB:getPokesData()
    local pokes = self._goLinkRules:myGoLinkPoke(pokes_data, oldSelPoke)
    if not pokes then
        return nil
    end
    Game.DDZPlayCom:doUnSelectAllPokes()
    for k,v in ipairs(pokes) do
        Game.DDZPlayCom:onPokeSelected(v)
    end
    Game.DDZPlayDB:setSelectedPoke(pokes)
    return true
end

--@ 用于确定牌，不可用于癞子牌
function M:getPokeType(poke)
    self._ddzPX:clearCheckType()
    self:selectedPokeJuge(poke, self._ddzPX)
    local type = self._ddzPX:getCheckType()
    local beginNum = self._ddzPX:getBeginNum()
    return type, beginNum
end

function M:getSmallestNum(lastdata)
    local smallNum = 999
    for k,v in pairs(lastdata) do
        if smallNum > v.num then
            smallNum = v.num
        end
    end
    return smallNum
end

function M:getSmallestNum_three(lastdata)
    local smallNum = 999
    local dataClone = table.newclone(lastdata)
    local pokes = self:findSamePokeWithNum(3, dataClone)
    while pokes ~= nil do
        local num = lastdata[pokes[1]].num
        if smallNum > num then
            smallNum = num
        end
        Game.DDZUtil:clearTableBySeq(pokes, dataClone)
        pokes = self:findSamePokeWithNum(3, dataClone)
    end
    return smallNum
end

function M:getSmallestNum_four(lastdata)
    local dataClone = table.newclone(lastdata)
    -- dump(dataClone)
    local pokes = self:findSamePokeWithNum(4, dataClone)
    return lastdata[pokes[1]].num
end

function M:checkToRoundTypeNum(type, num)
    if self._roundType == nil or self._mainRoundPokeNum == nil then
        return true
    end

    if type == PaiXing.CARD_TYPE_ZHA_DAN then
        if self._roundType == PaiXing.CARD_TYPE_WANG_ZHA then
            return false
        elseif self._roundType == type then
            local isRoundLz = Game.DDZPlayDB:isRoundHasLZ()
            local change = self:getLaiZiChange()
            local isSelPokeLZ = false
            if #change > 0 then
                isSelPokeLZ = true
            end
            if isRoundLz == true and isSelPokeLZ == false then
                return true
            elseif isRoundLz == false and isSelPokeLZ == true then
                return false
            else
                if self._mainRoundPokeNum < num then
                    return true
                end
            end
        else
            return true
        end
    elseif type == PaiXing.CARD_TYPE_WANG_ZHA then
        return true
    else
        if self._roundType == type and self._mainRoundPokeNum < num then
            return true
        end
    end
    return false
end

function M:getKeyLastNum(lastdata, dataType)
    local pokeType = dataType
    if pokeType == nil then
        pokeType = self._roundType
    end
    -- dump(pokeType)

    if pokeType == PaiXing.CARD_TYPE_DAN_ZHANG
        or pokeType == PaiXing.CARD_TYPE_SHUANG
        or pokeType == PaiXing.CARD_TYPE_SAN_ZHANG
        or pokeType == PaiXing.CARD_TYPE_ZHA_DAN then
        return lastdata[1].num
    elseif pokeType == PaiXing.CARD_TYPE_SAN_DAI_YI
        or pokeType == PaiXing.CARD_TYPE_SAN_DAI_ER then
        local allNums = Game.DDZUtil:buildAllNums(lastdata)
        for i,v in ipairs(allNums) do
            local sames = Game.DDZUtil:findSamePoke(v, lastdata)
            if #sames >= 3 then
                return v
            end
        end
        -- dump(allNums)
        -- dump(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_DAN_SHUN  then
        local shunNum = table.nums(lastdata)
        return self:getSmallestNum(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_LIAN_DUI  then
        local shunNum = table.nums(lastdata)
        local smallNum = self:getSmallestNum(lastdata)
        return smallNum
    elseif pokeType == PaiXing.CARD_TYPE_FEI_JI  then
        local shunNum = table.nums(lastdata)
        return self:getSmallestNum(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_CHI_BANG1  then
        local shunNum = table.nums(lastdata)
        return self:getSmallestNum_three(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_CHI_BANG2  then
        local shunNum = table.nums(lastdata)
        return self:getSmallestNum_three(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_WANG_ZHA  then
        return self:getSmallestNum(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_SI_DAN_ER1  then
        local shunNum = table.nums(lastdata)
        return self:getSmallestNum_four(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_SI_DAN_ER2  then
        local shunNum = table.nums(lastdata)
        return self:getSmallestNum_four(lastdata)
    end
    return nil
end

function M:rebackToFind(isUseBomb)
    if isUseBomb == true then
        local pokeType = self._roundType
        if pokeType == PaiXing.CARD_TYPE_ZHA_DAN then
            if self._lastMainPokeNum == self._mainRoundPokeNum then
                return false
            end
            self._lastMainPokeNum = self._mainRoundPokeNum
        else
            self._lastMainPokeNum = 0
        end
    else
        if self._lastMainPokeNum == self._mainRoundPokeNum then
            return false
        end
        self._lastMainPokeNum = self._mainRoundPokeNum
    end
    return true
end

function M:buildLastPokeNum()
    local lastPokes = Game.DDZPlayDB:getRoundPokes()
    if lastPokes == nil then
        return
    end
    local lastdata = Game.DDZPlayCom:converSvrPokeToClient(lastPokes)
    self._lastMainPokeNum = nil
    local num, pokeNum = self:getKeyLastNum(lastdata)
    self._lastMainPokeNum = num
    self._mainRoundPokeNum = num
end

function M:turnToMe()
    self._mainRoundPokeNum = nil
    self._roundType = nil
    local pokeData = Game.DDZPlayDB:getPokesData()
    self._toSelectPokes = table.newclone(pokeData)
    local isFollow = Game.DDZPlayDB:isFollowPoke()
    self._needFeiJiNum = nil
    self._needShunNum = nil
    if isFollow == true then
        self._roundType = self:getRoundPokeType()
        -- dump(self._roundType)
        self:buildLastPokeNum()
        self._needFeiJiNum = self._ddzPX:getFeiJiNum()
        self._needShunNum = self._ddzPX:getShunNum()
    end
    self._useBombFunc = nil
    self._autoSelectStep = 1
end

function M:converLZToOri(inputData, laiziChange)
    local nums = {}
    for k,v in pairs(inputData) do
        table.insert(nums, v.svrNum)
    end

    local svrLaizis = {}
    for k,v in pairs(laiziChange) do
        local oriCard = v[1]
        local changeCard = v[2]
        table.insert(svrLaizis, {oriCard, changeCard})
    end

    local mapLaiZi = {}
    for k,v in pairs(svrLaizis) do
        mapLaiZi[v[1]] = v[2]
    end

    for k,v in pairs(nums) do
        if mapLaiZi[v] ~= nil then
            nums[k] = mapLaiZi[v]
        end
    end
    return nums
end

function M:selectedPokeJuge_chuPai(selectedPokes)
    local pxfun = self._ddzPX_LZ
    local retPokes = nil
    local pokeNum = #selectedPokes
    if pokeNum == 0 then
        return nil
    end

    local isFollow = Game.DDZPlayDB:isFollowPoke()
    if isFollow == true then
        local pokeType = self._roundType
        if pokeNum == 1 then
            retPokes = pxfun:findOnePoke(selectedPokes)
        elseif pokeNum == 2 then
            if pokeType == PaiXing.CARD_TYPE_WANG_ZHA  then
                --retPokes = pxfun:findTwoJoker(selectedPokes)
            else
                retPokes = pxfun:findDoublePoke(selectedPokes)
            end
        elseif pokeNum == 3 then
            retPokes = pxfun:findThree(selectedPokes)

        elseif pokeNum == 4 then
            if pokeType == PaiXing.CARD_TYPE_ZHA_DAN  then
                retPokes = pxfun:findBomb(selectedPokes)
            elseif pokeType == PaiXing.CARD_TYPE_SAN_DAI_YI  then
                retPokes = pxfun:findThreeWithOne(selectedPokes)
            end

        elseif pokeNum == 5 then
            if pokeType == PaiXing.CARD_TYPE_SAN_DAI_ER then
                retPokes = pxfun:findThreeWithDouble(selectedPokes)
            end

        elseif pokeNum == 6 then
            if pokeType == PaiXing.CARD_TYPE_SI_DAN_ER1  then
                retPokes = pxfun:fourWithTwoSingle(selectedPokes)

            elseif pokeType == PaiXing.CARD_TYPE_FEI_JI  then
                retPokes = pxfun:findFeiJiPoke(selectedPokes)
            end

        elseif pokeNum == 8 then
            if pokeType == PaiXing.CARD_TYPE_SI_DAN_ER2  then
                retPokes = pxfun:fourWithTwoPair(selectedPokes)
            end
        end

        if retPokes == nil then
            if pokeType == PaiXing.CARD_TYPE_DAN_SHUN  then
                retPokes = pxfun:findShunZi(selectedPokes)
            elseif pokeType == PaiXing.CARD_TYPE_LIAN_DUI  then
                retPokes = pxfun:findThreeOrMoreDoublePoke(selectedPokes)
            elseif pokeType == PaiXing.CARD_TYPE_FEI_JI  then
                retPokes = pxfun:findFeiJiPoke(selectedPokes)
            elseif pokeType == PaiXing.CARD_TYPE_CHI_BANG1  then
                retPokes = pxfun:findFeiJiWithOne(selectedPokes)
            elseif pokeType == PaiXing.CARD_TYPE_CHI_BANG2  then
                retPokes = pxfun:findFeiJiWithTwo(selectedPokes)
            end
        end

        if pokeType ~= PaiXing.CARD_TYPE_ZHA_DAN  then
            local bombPokes = pxfun:findBomb(selectedPokes)
            if bombPokes ~= nil then
                retPokes = bombPokes
            end
        end

        if retPokes == nil then
            retPokes = pxfun:findBomb(selectedPokes)
        end
    else
        if pokeNum == 1 then
            retPokes = pxfun:findOnePoke(selectedPokes)
        elseif pokeNum == 2 then
            retPokes = pxfun:findBomb(selectedPokes)
                    or pxfun:findDoublePoke(selectedPokes)
        elseif pokeNum == 3 then
            retPokes = pxfun:findThree(selectedPokes)
        elseif pokeNum == 4 then
            retPokes = pxfun:findBomb(selectedPokes)
                    or pxfun:findThreeWithOne(selectedPokes)
        elseif pokeNum == 5 then
            retPokes = pxfun:findThreeWithDouble(selectedPokes)
        elseif pokeNum == 6 then
            retPokes = pxfun:fourWithTwoSingle(selectedPokes)
                    or pxfun:findFeiJiPoke(selectedPokes)
                    or pxfun:findThreeOrMoreDoublePoke(selectedPokes)
                    or pxfun:findShunZi(selectedPokes)
        elseif pokeNum == 7 then
            retPokes = pxfun:findShunZi(selectedPokes)
        elseif pokeNum == 8 then
            retPokes = pxfun:fourWithTwoPair(selectedPokes)
        end

        if retPokes == nil then
            retPokes = pxfun:findFeiJiPoke(selectedPokes)
            or pxfun:findFeiJiWithOne(selectedPokes)
            or pxfun:findFeiJiWithTwo(selectedPokes)
            or pxfun:findThreeOrMoreDoublePoke(selectedPokes)
            or pxfun:findShunZi(selectedPokes)
        end
    end
    return retPokes
end

function M:selectedPokeJuge(selectedPokes, pxfun)
    if pxfun == nil then
        pxfun = self._ddzPX_LZ
    end
    local retPokes = nil
    local pokeNum = #selectedPokes
    if pokeNum == 0 then
        return nil
    end

    if pokeNum == 1 then
        retPokes = pxfun:findOnePoke(selectedPokes)
    elseif pokeNum == 2 then
        retPokes = pxfun:findBomb(selectedPokes)
        if retPokes == nil then
            retPokes = pxfun:findDoublePoke(selectedPokes)
        end

    elseif pokeNum == 3 then
        retPokes = pxfun:findThree(selectedPokes)
    elseif pokeNum == 4 then
        retPokes = pxfun:findBomb(selectedPokes)
        if retPokes == nil then
            retPokes = pxfun:findThreeWithOne(selectedPokes)
        end
    elseif pokeNum == 5 then
        retPokes = pxfun:findThreeWithDouble(selectedPokes)
    elseif pokeNum == 6 then
        retPokes = pxfun:fourWithTwoSingle(selectedPokes)
    elseif pokeNum == 8 then
        retPokes = pxfun:fourWithTwoPair(selectedPokes)
    end

    if retPokes == nil then
        retPokes = pxfun:findShunZi(selectedPokes)
        or pxfun:findThreeOrMoreDoublePoke(selectedPokes)
        or pxfun:findFeiJiPoke(selectedPokes)
        or pxfun:findFeiJiWithOne(selectedPokes)
        or pxfun:findFeiJiWithTwo(selectedPokes)

    end
    return retPokes
end

paixingFunc = {
    M.noBigPoke,
    M.findBombStep,
    M.findOnePoke,
    M.findDoublePoke,
    M.findThree,
    M.findThreeWithOne,
    M.findThreeWithDouble,
    M.findShunZi,
    M.findThreeOrMoreDoublePoke,
    M.findFeiJiPoke,
    M.findFeiJiWithOne,
    M.findFeiJiWithTwo,
    M.fourWithTwoSingle,
    M.fourWithTwoPair,
}

return M
