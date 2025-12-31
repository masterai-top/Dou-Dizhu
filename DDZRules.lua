-- @Author: WangZh
-- @Date:   2016-07-22 09:55:15
-- @Last Modified by:   WangZh
-- @Last Modified time: 2016-07-22 09:57:36

local paixingFunc = {}

local aiAllStep = {
    [1] = 1,
    [2] = 1,
    [3] = 5,
    [4] = 3,
    [5] = 2,
    [6] = 2,
    [7] = 2,
    [8] = 4,
    [9] = 3,
    [10] = 2,
    [11] = 2,
    [12] = 2,
    [13] = 1,
    [14] = 1,
}

local M = class("DDZRules")

function M:ctor()
    self._toSelectPokes = {}
    self._hasSelectTipsPoke = {}
    self._ddzPX = require_ex("games.ddz.models.DDZPaiXing"):new()
    self._tgRules = require_ex("games.ddz.models.DDZRulesTG"):new()
    self._goLinkRules = require_ex("games.ddz.models.DDZRulesGoLinkClassic"):new()
    self._useBombFunc = nil
    self._mainRoundPokeNum = nil
    self._roundType = nil
    self._autoSelectStep = 1
    self._needFeiJiNum = nil
    self._needShunNum = nil
end

function M:fourWithTwoPair(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone

    local pokes = self:findSamePokeWithNum(4, dataClone)
    if pokes ~= nil then
        for k,v in pairs(pokes) do
            table.insert(retPokes, v)
        end
        local num = dataClone[retPokes[1]].num
        local allPoke = Game.DDZPlayDB:getPokesData()
        local allClone = table.newclone(allPoke)
        Game.DDZUtil:clearTableByNum(num, allClone)

        local retOnes = self:findMoreTwoNotMain(allClone, 4)

        if retOnes ~= nil then
            local outIdx = {}
            for k,v in pairs(retOnes) do
                table.insert(outIdx, v)
            end
            return retPokes, outIdx
        end
    end
    return nil
end

function M:fourWithTwoSingle(inData)
    local retPokes = {}
    local pokeData = inData

    local dataClone = table.newclone(pokeData)
    local pokeNum = #dataClone

    local pokes = self:findSamePokeWithNum(4, dataClone)
    if pokes ~= nil then
        for k,v in pairs(pokes) do
            table.insert(retPokes, v)
        end
        local num = dataClone[retPokes[1]].num
        local allPoke = Game.DDZPlayDB:getPokesData()
        local allClone = table.newclone(allPoke)
        Game.DDZUtil:clearTableByNum(num, allClone)

        local retOnes = self:findMoreOneNotMain(allClone, 2)

        if retOnes ~= nil then
            local outIdx = {}
            for k,v in pairs(retOnes) do
                table.insert(outIdx, v)
            end
            return retPokes, outIdx
        end
    end
    return nil
end

function M:checkShunZi(shunzi_nums)
    if not shunzi_nums or type(shunzi_nums) ~= "table" then
        return false
    end
    local isOk = true
    local stepRuleFound = false
    for iRet,vRet in ipairs(shunzi_nums) do
        if self._autoSelectStep == 1 then
            local checkOk = Game.DDZUtil:checkSinglePoke(vRet)
            if checkOk == false then
                isOk = false
                break
            end
            stepRuleFound = true
        elseif self._autoSelectStep == 2 then
            local checkOne = Game.DDZUtil:checkSinglePoke(vRet)
            local checkDouble = Game.DDZUtil:checkDoublePoke(vRet)
            local checkOk = (checkOne or checkDouble)

            if checkOk == false then
                isOk = false
                break
            end
            if checkDouble == true then
                stepRuleFound = true
            end
        elseif self._autoSelectStep == 3 then
            local checkOne = Game.DDZUtil:checkSinglePoke(vRet)
            local checkDouble = Game.DDZUtil:checkDoublePoke(vRet)
            local checkThree = Game.DDZUtil:checkThreePoke(vRet)
            local checkOk = (checkOne or checkDouble or checkThree)
            if checkOk == false then
                isOk = false
                break
            end
            if checkThree == true then
                stepRuleFound = true
            end
        elseif self._autoSelectStep == 4 then
            local checkOne = Game.DDZUtil:checkSinglePoke(vRet)
            local checkDouble = Game.DDZUtil:checkDoublePoke(vRet)
            local checkThree = Game.DDZUtil:checkThreePoke(vRet)
            local checkFour = Game.DDZUtil:checkFourPoke(vRet)
            local checkOk = (checkOne or checkDouble or checkThree or checkFour)
            if checkOk == false then
                isOk = false
                break
            end

            if checkFour == true then
                stepRuleFound = true
            end
        end
    end
    if stepRuleFound == false then
        isOk = false
    end
    return isOk
end

--@ 获取顺子牌
function M:findShunZi(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local shunNum = self._needShunNum
    local pokesNum = #dataClone

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local numCnt = #allNums

    local retPokes = {}
    local shunziNums = {}

    for i,v in ipairs(allNums) do
        shunziNums = {}
        local needValue = v
        for j=i,numCnt do
            if needValue >= TWO then
                break
            end
            if allNums[j] == needValue then
                table.insert(shunziNums, needValue)
                local collectSZ = #shunziNums
                if collectSZ == shunNum then
                    local isOk = self:checkShunZi(shunziNums)
                    if isOk == true then
                        retPokes = {}
                        for iRet,vRet in ipairs(shunziNums) do
                            local samePokes = Game.DDZUtil:findSamePoke(vRet, dataClone)
                            table.insert(retPokes, samePokes[1])
                        end
                        return retPokes
                    else
                        break
                    end
                end
                needValue = needValue + 1
            else
                break
            end
        end
    end
    return nil
end

function M:checkThreeOrMoreDoublePoke(shunziNums)
    if not shunziNums or type(shunziNums) ~= "table" then
        return
    end
    local isOk = true
    local stepRuleFound = false
    for iRet,vRet in ipairs(shunziNums) do
        if self._autoSelectStep == 1 then
            local checkOk = Game.DDZUtil:checkDoublePoke(vRet)
            if checkOk == false then
                isOk = false
                break
            else
                stepRuleFound = true
            end
        elseif self._autoSelectStep == 2 then
            local checkDouble = Game.DDZUtil:checkDoublePoke(vRet)
            local checkThree = Game.DDZUtil:checkThreePoke(vRet)
            if (checkThree or checkDouble) == false then
                isOk = false
                break
            end

            if checkThree == true then
                stepRuleFound = true
            end
        elseif self._autoSelectStep == 3 then
            local checkDouble = Game.DDZUtil:checkDoublePoke(vRet)
            local checkThree = Game.DDZUtil:checkThreePoke(vRet)
            local checkFour = Game.DDZUtil:checkFourPoke(vRet)
            if (checkThree or checkDouble or checkFour) == false then
                isOk = false
                break
            end

            if checkFour == true then
                stepRuleFound = true
            end
        end
    end
    if stepRuleFound == false then
        isOk = false
    end
    return isOk  
end

function M:findThreeOrMoreDoublePoke(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local totalRoundPoke = self._needShunNum*2
    local pokesNum = #dataClone

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local numCnt = #allNums
    if #pokeData < totalRoundPoke then
        return nil
    end
    local shunNum = totalRoundPoke/2

    local retPokes = {}
    local shunziNums = {}
    for i,v in ipairs(allNums) do
        shunziNums = {}
        local needValue = v
        for j=i,numCnt do
            if needValue >= TWO then
                break
            end
            if allNums[j] == needValue then
                table.insert(shunziNums, needValue)
                if #shunziNums == shunNum then
                    local isOk = self:checkThreeOrMoreDoublePoke(shunziNums)
                    if isOk == true then
                        retPokes = {}
                        for iRet,vRet in ipairs(shunziNums) do
                            local samePokes = Game.DDZUtil:findSamePoke(vRet, dataClone)
                            table.insert(retPokes, samePokes[1])
                            table.insert(retPokes, samePokes[2])
                        end
                        return retPokes
                    else
                        break
                    end
                end
                needValue = needValue + 1
            else
                break
            end
        end
    end
    return nil
end

function M:checkFeiJiPoke(shunziNums)
    if not shunziNums or type(shunziNums) ~= "table" then
        return
    end
    local isOk = true
    local stepRuleFound = false
    for iRet,vRet in ipairs(shunziNums) do
        if self._autoSelectStep == 1 then
            local checkOk = Game.DDZUtil:checkThreePoke(vRet)
            if checkOk == false then
                isOk = false
                break
            else
                stepRuleFound = true
            end
        elseif self._autoSelectStep == 2 then
            local checkOkThree = Game.DDZUtil:checkThreePoke(vRet)
            local checkOkFour = Game.DDZUtil:checkFourPoke(vRet)

            if (checkOkThree or checkOkFour) == false then
                isOk = false
                break
            else
                if checkOkFour == true then
                    stepRuleFound = true
                end
            end
        end
    end
    if stepRuleFound == false then
        isOk = false
    end
    return isOk
end

function M:findFeiJiPoke(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    if self._needFeiJiNum == nil then
        Log(LOG.TAG.DDZ, LOG.LV.ERROR, "=====findFeiJiPoke _needFeiJiNum is null=====")
        return
    end
    local feijiNum = self._needFeiJiNum
    local totalRoundPoke = feijiNum*3
    local pokesNum = #dataClone

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    local numCnt = #allNums
    local shunNum = feijiNum
    local retPokes = {}
    local shunziNums = {}

    for i,v in ipairs(allNums) do
        shunziNums = {}
        local needValue = v
        for j=i,numCnt do
            if needValue >= TWO then
                break
            end
            if allNums[j] == needValue then
                table.insert(shunziNums, needValue)
                if #shunziNums == shunNum then
                    local isOk = self:checkFeiJiPoke(shunziNums)
                    if isOk == true then
                        retPokes = {}
                        for iRet,vRet in ipairs(shunziNums) do
                            local samePokes = Game.DDZUtil:findSamePoke(vRet, dataClone)
                            table.insert(retPokes, samePokes[1])
                            table.insert(retPokes, samePokes[2])
                            table.insert(retPokes, samePokes[3])
                        end
                        return retPokes
                    else
                        break
                    end
                end
                needValue = needValue + 1
            else
                break
            end
        end
    end
    return nil
end

function M:findMoreOneNotMain(inData, moreNum)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = {}
    for i=1,4 do
        collect[i] = {}
    end

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)

    for i,v in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(v, dataClone)
        if #sames == 1 then
            table.insert(collect[1], v)
        elseif #sames == 2 then
            table.insert(collect[2], v)
        elseif #sames == 3 then
            table.insert(collect[3], v)
        elseif  #sames == 4 then
            table.insert(collect[4], v)
        end
    end

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

function M:findMoreTwoNotMain(inData, moreNum)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = {}
    for i=1,4 do
        collect[i] = {}
    end

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)

    for i,v in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(v, dataClone)
        if #sames == 2 then
            table.insert(collect[2], v)
        elseif #sames == 3 then
            table.insert(collect[3], v)
        elseif  #sames == 4 then
            table.insert(collect[4], v)
        end
    end

    collect[1] = {}

    for iCo,vCo in ipairs(collect) do
        for iVa,vVa in ipairs(vCo) do
            local sames = Game.DDZUtil:findSamePoke(vVa, dataClone)
            if iCo == 3 or iCo == 2 then
                table.insert(retPokes, dataClone[sames[1]].index)
                table.insert(retPokes, dataClone[sames[2]].index)
                if #retPokes == moreNum then
                    return retPokes
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
    return nil
end

function M:findFeiJiWithOne(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local retPokes = self:findFeiJiPoke(dataClone)
    if retPokes ~= nil then
        local allPoke = Game.DDZPlayDB:getPokesData()
        local allClone = table.newclone(allPoke)
        local retNums = Game.DDZUtil:buildIndexAllNums(retPokes, dataClone, true)
        for i,v in ipairs(retNums) do
            -- dump(retNums)
            Game.DDZUtil:clearTableByNum(v, allClone, 3)
        end

        local feijiNum = self._needFeiJiNum

        local retOnes = self:findMoreOneNotMain(allClone, feijiNum)

        if retOnes ~= nil then
            local outIdx = {}
            for k,v in pairs(retOnes) do
                table.insert(outIdx, v)
            end
            return retPokes, outIdx
        end
    end

    return nil
end

function M:findFeiJiWithTwo(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local retPokes = self:findFeiJiPoke(dataClone)
    if retPokes ~= nil then
        -- dump(retPokes)
        local allPoke = Game.DDZPlayDB:getPokesData()
        local allClone = table.newclone(allPoke)
        local retNums = Game.DDZUtil:buildIndexAllNums(retPokes, dataClone, true)
        for i,v in ipairs(retNums) do
            -- dump(retNums)
            Game.DDZUtil:clearTableByNum(v, allClone, 3)
        end

        -- dump(allClone)

        local feijiNum = self._needFeiJiNum

        local retOnes = self:findMoreTwoNotMain(allClone, feijiNum*2)

        if retOnes ~= nil then
            local outIdx = {}
            for k,v in pairs(retOnes) do
                table.insert(outIdx, v)
            end
            return retPokes, outIdx
        end
    end

    return nil
end

function M:findTwoJoker(inData)
    local retPokes = {}
    local pokeData = nil
    if inData ~= nil then
        pokeData = inData
    else
        pokeData = Game.DDZPlayDB:getPokesData()
    end

    local allNum = table.nums(pokeData)
    for k,data in pairs(pokeData) do
        local num = data.num
        if num == BIG_JOKER then
            table.insert(retPokes, k)
        elseif num == SMALL_JOKER then
            table.insert(retPokes, k)
        end
    end
    if #retPokes == 2 then

        return retPokes
    end
    return nil
end

function M:selectPokeByPX(paixing)

end

function M:noBigPoke()
    Game.DDZPlayCom:onEvent(DDZEvent.DDZ_SHOW_NO_BIG_POKE_EVENT, {isShow = true})
end

function M:findSamePokeWithNum(sameNum, inData)
    return Game.DDZUtil:findSameCountPoke(sameNum, inData)
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
    while pokes ~= nil do
        local num = dataClone[pokes[1]].num
        local sames = Game.DDZUtil:findSamePoke(num, dataClone)

        if self._autoSelectStep == 1 then
            if #sames == 3 then
                for k,v in pairs(pokes) do
                    table.insert(retPokes, v)
                end
                break
            else
                Game.DDZUtil:clearTableByNum(num, dataClone)
            end
        elseif self._autoSelectStep == 2 then
            if #sames == 4 then
                for k,v in pairs(pokes) do
                    table.insert(retPokes, v)
                end
                break
            else
                Game.DDZUtil:clearTableByNum(num, dataClone)
            end

        end
        pokes = self:findSamePokeWithNum(3, dataClone)
    end

    local retPokeNum = #retPokes
    if retPokeNum == 3 then
        return retPokes
    end
    return nil
end

function M:findDoublePoke(inData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)

    for iNum,vNum in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(vNum, dataClone)
        local checkOk = false
        if self._autoSelectStep == 1 then
            if #sames == 2 then
                checkOk = true
            end
        elseif self._autoSelectStep == 2 then
            if #sames == 3 then
                checkOk = true
            end
        elseif self._autoSelectStep == 3 then
            if #sames == 4 then
                checkOk = true
            end
        end
        if checkOk == true then
            for i=1,2 do
                table.insert(retPokes, sames[i])
            end
            break
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

    local allNum = table.nums(pokeData)

    for i=allNum, 1, -1 do
        local thisNum = pokeData[i].num

        if self._autoSelectStep == 1 then
            local checkOk = Game.DDZUtil:checkSinglePoke(thisNum)
            if checkOk == true then
                table.insert(retPokes, i)
                break
            end
        elseif self._autoSelectStep == 2 then
            local checkOk = Game.DDZUtil:checkDoublePoke(thisNum)
            if checkOk == true then
                table.insert(retPokes, i)
                break
            end
        elseif self._autoSelectStep == 3 then
            local checkOk = Game.DDZUtil:checkThreePoke(thisNum)
            if checkOk == true then
                table.insert(retPokes, i)
                break
            end
        elseif self._autoSelectStep == 4 then
            -- local checkOk = Game.DDZUtil:checkShunZiPoke(thisNum)
            local checkOk = false
            if checkOk == true then
                table.insert(retPokes, i)
                break
            end
        elseif self._autoSelectStep == 5 then
            local checkOk = Game.DDZUtil:checkFourPoke(thisNum)
            if checkOk == true then
                table.insert(retPokes, i)
                break
            end
        end
    end
    if #retPokes == 1 then
        return retPokes
    end
    return nil
end

function M:findOneNotMain(inData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = {-1, -1, -1}

    local allNums = Game.DDZUtil:buildAllNums(dataClone)

    for i,v in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(v, dataClone)
        if #sames == 1 then
            local idx = sames[1]
            --if not Game.DDZUtil:checkDaXiaoWang(dataClone, idx) then
                collect[1] = v
            --end
        elseif #sames == 2 then
            collect[2] = v
        else
            collect[3] = v
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

function M:findDoubleNotMain(inData)
    local retPokes = {}
    local pokeData = inData
    local dataClone = table.newclone(pokeData)
    local collect = {-1, -1, -1}

    local allNums = Game.DDZUtil:buildAllNums(dataClone)

    for i,v in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(v, dataClone)
        if #sames == 2 then
            local idx1 = sames[1]
            local idx2 = sames[2]
            if not Game.DDZUtil:checkDaXiaoWang(dataClone, idx1) 
                and not Game.DDZUtil:checkDaXiaoWang(dataClone, idx2) then
                collect[1] = v
            end
        elseif #sames == 3 then
            collect[2] = v
        elseif #sames == 4 then
            collect[3] = v
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

function M:findThreeWithOne(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local allPokeCnt = Game.DDZPlayDB:getNowPokeNum()

    if allPokeCnt < 4 then
        return nil
    end
    local retPokes = {}

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)

    for i,v in ipairs(allNums) do
        retPokes = {}
        local isOk = false
        if self._autoSelectStep == 1 then
            local checkOk = Game.DDZUtil:checkThreePoke(v)
            if checkOk == true then
                isOk = true
            end
        elseif self._autoSelectStep == 2 then
            local checkOk = Game.DDZUtil:checkFourPoke(v)
            if checkOk == true then
                isOk = true
            end
        end

        if isOk == true then
            local sames = Game.DDZUtil:findSamePoke(v, dataClone)

            for iSame = 1,3 do
                table.insert(retPokes, sames[iSame])
            end

            local allPoke = Game.DDZPlayDB:getPokesData()
            local allClone = table.newclone(allPoke)

            Game.DDZUtil:clearTableByNum(v, allClone, 3)

            local retOne = self:findOneNotMain(allClone)

            if retOne ~= nil then
                local oneNum = retOne[1]
                for k,v in pairs(allClone) do
                    if oneNum == v.num then
                        return retPokes,{v.index}
                    end
                end
            end
        end
    end
    return nil
end

function M:findThreeWithDouble(inData)
    local pokeData = inData
    local dataClone = table.newclone(pokeData)

    local allPokeCnt = Game.DDZPlayDB:getNowPokeNum()

    if allPokeCnt < 5 then
        return nil
    end
    local retPokes = {}

    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)

    for i,v in ipairs(allNums) do
        retPokes = {}
        local isOk = false
        if self._autoSelectStep == 1 then
            local checkOk = Game.DDZUtil:checkThreePoke(v)
            if checkOk == true then
                isOk = true
            end
        elseif self._autoSelectStep == 2 then
            local checkOk = Game.DDZUtil:checkFourPoke(v)
            if checkOk == true then
                isOk = true
            end
        end

        if isOk == true then
            local sames = Game.DDZUtil:findSamePoke(v, dataClone)

            for iSame = 1,3 do
                table.insert(retPokes, sames[iSame])
            end

            local allPoke = Game.DDZPlayDB:getPokesData()
            local allClone = table.newclone(allPoke)

            Game.DDZUtil:clearTableByNum(v, allClone, 3)

            local retOne = self:findDoubleNotMain(allClone)

            if retOne ~= nil then
                local oneNum = retOne[1]
                local outIdx = {}
                for k,v in pairs(allClone) do
                    if oneNum == v.num then
                        table.insert(outIdx, v.index)
                        if #outIdx == 2 then
                            return retPokes, outIdx
                        end
                    end
                end
            end
        end
    end
    return nil
end

function M:findBombFour(inData, bombNum)
    local dataClone = table.newclone(inData)
    local allNums = Game.DDZUtil:buildAllNums(dataClone, true)
    for i,v in ipairs(allNums) do
        local sames = Game.DDZUtil:findSamePoke(v, dataClone)
        if #sames == 4 and v > bombNum then
            return sames
        end
    end
    return nil
end

function M:findBomb(inData)
    local retPokes = {}
    local pokeData = inData

    local pokesNum = #pokeData
    if pokesNum < 4 then
        local pokes = self:findTwoJoker(pokeData)
        if pokes ~= nil then
            if #pokes == 2 then
                return pokes
            end
        end
    else
        local pokes = nil
        if self._roundType == PaiXing.CARD_TYPE_ZHA_DAN then
            pokes = self:findBombFour(pokeData, self._mainRoundPokeNum)
            if pokes ~= nil then
                for k,v in pairs(pokes) do
                    table.insert(retPokes, v)
                end
            end
        else
            pokes = self:findSamePokeWithNum(4, pokeData)
            if pokes ~= nil then
                for k,v in pairs(pokes) do
                    table.insert(retPokes, v)
                end
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

local quickGoPokeFunc = {
    M.findThree,
    M.findDoublePoke,
    M.findOnePoke,
}

function M:checkCanQuickGo(inData)
    local pokeData = inData

    local pokesNum = #pokeData
    local dataClone = table.newclone(pokeData)
    local ret = false
    for i,v in ipairs(quickGoPokeFunc) do
        local pokeRet = v(self, dataClone)
        if pokeRet ~= nil then
            local retNum = #pokeRet
            if retNum == pokesNum then
                return true
            end
        end
    end

    if pokesNum == 4 then
        ret = self._ddzPX:findThreeWithOne(dataClone)~=nil
    elseif pokesNum == 5 then
        ret = self._ddzPX:findThreeWithDouble(dataClone)~=nil
    end

    return ret
end

function M:rebackToFind(isClear)
    local pokeData = Game.DDZPlayDB:getPokesData()
    self._toSelectPokes = table.newclone(pokeData)
    self._hasSelectTipsPoke = {}
    self._useBombFunc = nil
    if isClear == true then
        self:clearNoUsePoke()
    end
end

function M:autoSelectPoke_SimpleAi(pokeType)
    if table.nums(self._hasSelectTipsPoke) > 0 then
        self:clearTipsPoke()
    end
    local pokes = nil
    local outSelPokes = nil

    if self._useBombFunc ~= nil then
        pokes = self._useBombFunc(self, self._toSelectPokes)
        if pokes == nil then
            self._useBombFunc = nil
            self:rebackToFind(true)
            self._autoSelectStep = 1
        end
    end

    if pokes == nil then
        local func = paixingFunc[pokeType]
        for i=self._autoSelectStep,aiAllStep[pokeType] do
            pokes, outSelPokes = func(self, self._toSelectPokes)
            if pokes ~= nil then
                break
            else
                self:rebackToFind(true)
                self._autoSelectStep = self._autoSelectStep + 1
            end
        end

        if pokes == nil then
            self:rebackToFind(false)
            pokes = self:findBomb(self._toSelectPokes)
            if pokes == nil then
                self:rebackToFind(true)
                self._autoSelectStep = 1
                for i=self._autoSelectStep,aiAllStep[pokeType] do
                    pokes, outSelPokes = func(self, self._toSelectPokes)
                    if pokes ~= nil then
                        break
                    else
                        self:rebackToFind(true)
                        self._autoSelectStep = self._autoSelectStep + 1
                    end
                end
            else
                self._useBombFunc = self.findBomb
            end
        end
    end

    if pokes ~= nil then
        self._hasSelectTipsPoke = pokes
        local pokeIdx = {}
        for i,v in ipairs(pokes) do
            local selPokeIdx = self._toSelectPokes[v].index
            table.insert(pokeIdx, selPokeIdx)
        end

        if outSelPokes ~= nil then
            for k,v in pairs(outSelPokes) do
                table.insert(pokeIdx, v)
            end
        end

        Game.DDZPlayDB:setSelectedPoke(pokeIdx)
        for k,v in pairs(pokeIdx) do
            Game.DDZPlayCom:onPokeSelected(v)
        end
    else
        self:noBigPoke()
        return false
    end
    return true
end

function M:autoSelectPoke()
    self._ddzPX:clearCheckType()
    local nowRoundState = Game.DDZPlayDB:getRoundState()
    if nowRoundState == 1 then
        local lastPokes = Game.DDZPlayDB:getRoundPokes()
        if lastPokes == nil then
            return
        end
        local lastdata = Game.DDZPlayCom:converSvrPokeToClient(lastPokes)
        local pokeType = self:getPokeType(lastdata)

        Log(LOG.TAG.DDZ, LOG.LV.INFO, "=====autoSelectPoke pokeType is: " .. tostring(pokeType))
        if pokeType == nil or (pokeType == PaiXing.CARD_TYPE_WANG_ZHA) then
            self:noBigPoke()
            return false
        end
        return self:autoSelectPoke_SimpleAi(pokeType)
    else
        local pokes = self._tgRules:myTurnGoPoke(Game.DDZPlayDB:getPokesData())
        local setSelPoke = {}
        for k,v in pairs(pokes) do
            Game.DDZPlayCom:onPokeSelected(v)
            table.insert(setSelPoke, v)
        end
        Game.DDZPlayDB:setSelectedPoke(setSelPoke)
    end
    return true
end

--检测是否有上家出牌，并且牌型不是炸弹，如有炸弹可出
function M:checkCanGoWithRoundPoke()
    self._ddzPX:clearCheckType()
    local lastPokes = Game.DDZPlayDB:getRoundPokes()
    if lastPokes == nil then
        return
    end
    local lastdata = Game.DDZPlayCom:converSvrPokeToClient(lastPokes)
    local pokeType = self:getPokeType(lastdata)
    if (pokeType~=PaiXing.CARD_TYPE_ZHA_DAN) and (pokeType ~= PaiXing.CARD_TYPE_WANG_ZHA) then
        if pokeType == nil then
            return nil
        end
        local pokesData = Game.DDZPlayDB:getPokesData()
        local retPoke = self:findBomb(pokesData)
        return retPoke~=nil
    else
        return nil
    end
end

-- 玩家首次出牌智能选中
function M:autoFulfillSelectPoke(oldSelPoke)
    -- 存在三张一样, 不处理
    -- local select_map = {}
    -- for i,v in ipairs(oldSelPoke or {}) do
    --     if not select_map[v.num] then
    --         select_map[v.num] = 0
    --     end
    --     select_map[v.num] = select_map[v.num] + 1

    --     if select_map[v.num] >= 3 then
    --         return false
    --     end
    -- end

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

function M:clearCheckType()
end

function M:getPokeType(poke)
    self._ddzPX:clearCheckType()
    self:selectedPokeJuge(poke)
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
    local smallNum = 999
    local dataClone = table.newclone(lastdata)
    local pokes = self:findSamePokeWithNum(4, dataClone)
    return lastdata[pokes[1]].num
end

function M:lastNumErrorDump(pokes, type, lastdata)
    if pokes == nil then
        Log(LOG.TAG.DDZ, LOG.LV.INFO, type)
        Log(LOG.TAG.DDZ, LOG.LV.INFO, lastdata)
    end
end

function M:getKeyLastNum(lastdata)
    local pokeType = self:getPokeType(lastdata)

    if pokeType == PaiXing.CARD_TYPE_DAN_ZHANG
        or pokeType == PaiXing.CARD_TYPE_SHUANG
        or pokeType == PaiXing.CARD_TYPE_SAN_ZHANG
        or pokeType == PaiXing.CARD_TYPE_ZHA_DAN then
        return lastdata[1].num
    elseif pokeType == PaiXing.CARD_TYPE_SAN_DAI_YI
        or pokeType == PaiXing.CARD_TYPE_SAN_DAI_ER then
        local pokes = self:findSamePokeWithNum(3, lastdata)
        self:lastNumErrorDump(pokes, pokeType, lastdata)
        return lastdata[pokes[1]].num
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
    elseif pokeType == PaiXing.CARD_TYPE_SI_DAN_ER1  then
        local shunNum = table.nums(lastdata)
        return self:getSmallestNum_four(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_SI_DAN_ER2  then
        local shunNum = table.nums(lastdata)
        return self:getSmallestNum_four(lastdata)
    elseif pokeType == PaiXing.CARD_TYPE_WANG_ZHA  then
        return self:getSmallestNum(lastdata)
    end
    return nil
end

function M:checkToRoundTypeNum(type, num)
    if self._roundType == nil and self._mainRoundPokeNum == nil then
        return true
    end

    if type == PaiXing.CARD_TYPE_ZHA_DAN then
        if self._roundType == PaiXing.CARD_TYPE_WANG_ZHA then
            return false
        elseif self._roundType == type then
            if self._mainRoundPokeNum < num then
                return true
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

function M:clearNoUsePoke()
    local lastPokes = Game.DDZPlayDB:getRoundPokes()
    if lastPokes == nil then
        return
    end

    local lastdata = Game.DDZPlayCom:converSvrPokeToClient(lastPokes)
    self._roundType = self:getPokeType(lastdata)
    local num, pokeNum = self:getKeyLastNum(lastdata)
    local tableNum = table.nums((self._toSelectPokes or {}))
    self._mainRoundPokeNum = num

    for i=tableNum, 1, -1 do
        local conpare = self._toSelectPokes[i].num
        if not conpare or not num or conpare <= num then
            table.remove(self._toSelectPokes, i)
        end
    end
end

function M:clearTipsPoke()
    local pokeData = {}
    for k,v in pairs(self._hasSelectTipsPoke) do
        table.insert(pokeData, self._toSelectPokes[v])
    end

    local num = self:getKeyLastNum(pokeData)
    Game.DDZUtil:clearTableByNum(num, self._toSelectPokes)
end

function M:turnToMe()
    self._mainRoundPokeNum = nil
    self._roundType = nil
    local pokeData = Game.DDZPlayDB:getPokesData()
    self._toSelectPokes = table.newclone(pokeData)
    self._hasSelectTipsPoke = {}

    self._useBombFunc = nil
    self._autoSelectStep = 1
    local isFollow = Game.DDZPlayDB:isFollowPoke()
    self._needFeiJiNum = nil
    self._needShunNum = nil
    if isFollow == true then
        self:clearNoUsePoke()
        self._needFeiJiNum = self._ddzPX:getFeiJiNum()
        self._needShunNum = self._ddzPX:getShunNum()
    end
end

function M:selectedPokeJuge(selectedPokes)
    local retPokes = nil
    local pokeNum = #selectedPokes
    if pokeNum == 0 then
        return nil
    end

    if pokeNum == 1 then
        retPokes = self._ddzPX:findOnePoke(selectedPokes)
    elseif pokeNum == 2 then
        retPokes = self._ddzPX:findBomb(selectedPokes)
        if retPokes == nil then
            retPokes = self._ddzPX:findDoublePoke(selectedPokes)
        end
    elseif pokeNum == 3 then
        retPokes = self._ddzPX:findThree(selectedPokes)
    elseif pokeNum == 4 then
        retPokes = self._ddzPX:findBomb(selectedPokes)
        if retPokes == nil then
            retPokes = self._ddzPX:findThreeWithOne(selectedPokes)
        end
    elseif pokeNum == 5 then
        retPokes = self._ddzPX:findThreeWithDouble(selectedPokes)
    elseif pokeNum == 6 then
        retPokes = self._ddzPX:fourWithTwoSingle(selectedPokes)
    elseif pokeNum == 8 then
        retPokes = self._ddzPX:fourWithTwoPair(selectedPokes)
    end

    if retPokes == nil then
        retPokes = self._ddzPX:findShunZi(selectedPokes)
        or self._ddzPX:findThreeOrMoreDoublePoke(selectedPokes)
        or self._ddzPX:findFeiJiPoke(selectedPokes)
        or self._ddzPX:findFeiJiWithOne(selectedPokes)
        or self._ddzPX:findFeiJiWithTwo(selectedPokes)
    end
    return retPokes
end

paixingFunc = {
    M.noBigPoke,
    M.findBomb,
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
