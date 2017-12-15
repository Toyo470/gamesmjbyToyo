--
-- Author: ZT
-- Date: 2016-09-22 10:34:17
--
--胡的结果

--  tb_test_json=[[
--  {"base":1,"cards":["3,8,19,9,35,20,1,2,3,41,19,9,25","36,37,3,22,9,20,40,38,18,41,20,23,39","34,19,5,22,17,20,33,7,4,7,40,33,40","35,37,6,8,5,65,25,5,39,35,21,8,41"],"frame":[{"card":21,"opeType":0,"operationBitset":0,"type":12290,"uid":821},{"card":25,"opeType":0,"operationBitset":0,"type":16644,"uid":821},{"card":24,"opeType":0,"operationBitset":0,"type":12290,"uid":818},{"card":41,"opeType":0,"operationBitset":0,"type":16644,"uid":818},{"card":24,"opeType":0,"operationBitset":0,"type":12290,"uid":819},{"card":18,"opeType":0,"operationBitset":0,"type":16644,"uid":819},{"card":34,"opeType":0,"operationBitset":0,"type":12290,"uid":820},{"card":5,"opeType":0,"operationBitset":0,"type":16644,"uid":820},{"card":5,"opeType":0,"operationBitset":8,"type":12293,"uid":821},{"card":5,"opeType":8,"operationBitset":0,"type":16389,"uid":821},{"card":6,"opeType":0,"operationBitset":0,"type":16644,"uid":821},{"card":2,"opeType":0,"operationBitset":0,"type":12290,"uid":818},{"card":35,"opeType":0,"operationBitset":0,"type":16644,"uid":818},{"card":35,"opeType":0,"operationBitset":8,"type":12293,"uid":821},{"card":35,"opeType":8,"operationBitset":0,"type":16389,"uid":821},{"card":41,"opeType":0,"operationBitset":0,"type":16644,"uid":821},{"card":23,"opeType":0,"operationBitset":0,"type":12290,"uid":818},{"card":8,"opeType":0,"operationBitset":0,"type":16644,"uid":818},{"card":8,"opeType":0,"operationBitset":72,"type":12293,"uid":821},{"card":8,"opeType":64,"operationBitset":0,"type":16389,"uid":821}],"gameTime":"1474708663","niaoCards":[18,65,17,38,7,38],"remainCardCount":60,"settlements":[{"anGangCount":0,"hu":{"fangPao":{"card":8,"fromUId":818,"isGangShangPao":0,"isQiangGangHu":0},"huType":1,"winMoney":0},"isFangPao":0,"isHu":1,"mingGangCount":0,"uid":821},{"anGangCount":0,"isFangPao":1,"isHu":0,"mingGangCount":0,"uid":818},{"anGangCount":0,"isFangPao":0,"isHu":0,"mingGangCount":0,"uid":819},{"anGangCount":0,"isFangPao":0,"isHu":0,"mingGangCount":0,"uid":820}],"userinfos":[{"chips":"992","level":1,"money":0,"nickName":"瀹儴鐒�","photoUrl":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/f9aff0a3-9c12-4fb4-81ca-4a9b36948661.jpg","score":-8,"sex":"2","uid":818},{"chips":"995","level":1,"money":0,"nickName":"鑹惧悜鏅�","photoUrl":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/f9aff0a3-9c12-4fb4-81ca-4a9b36948661.jpg","score":0,"sex":"2","uid":819},{"chips":"997","level":1,"money":0,"nickName":"瑁寸粡璧�","photoUrl":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/f9aff0a3-9c12-4fb4-81ca-4a9b36948661.jpg","score":0,"sex":"2","uid":820},{"chips":"1016","level":1,"money":0,"nickName":"璋㈠杩�","photoUrl":"http://hbirdtest.oss-cn-shenzhen.aliyuncs.com/507userHeader20160617104940.jpg","score":8,"sex":"2","uid":821}],"zhongNiaoCards":[65,17],"zhuang_id":3}


-- ]]



local CARD_TYPE = 
{ 
    "天胡",--1
    "地胡",--2
    "清龙七对",--3
    "龙七对",--4
    "清七对",--5
    "清幺九",--6
    "清对" ,--7
    "将对",--8
    "清一色",--9
    "全幺九 ",--10
    "七对",--11
    "对对胡",--12
    "平胡",--13
    "将七对",--14
    "门清",--15
    "中张",--16
}     --四川


local card_hu_type_cs={
	--// 小胡
	"四喜",
	"板板胡",
	"缺一色",
	"六六顺",
	"小胡",

	--// 大胡
	"天胡",
	"地胡",
	"碰碰胡",
	"将将胡",
	"清一色",
	"海底捞月",
	"海底炮",
	"七小对",
	"杠上开花",
	"全杠胡",
	"杠上跑",

	"七对胡",
	"全求人",

}--长沙麻将




local color_={
    [0]="wan",
    [1]="tong",
    [2]="tiao",
}


-- 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09
-- ============================================
-- Ò»Íò ¶þÍò ÈýÍò ËÄÍò ÎåÍò ÁùÍò ÆßÍò °ËÍò ¾ÅÍò
-- ============================================
-- 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19
-- ============================================
-- Ò»Í² ¶þÍ² ÈýÍ² ËÄÍ² ÎåÍ² ÁùÍ² ÆßÍ² °ËÍ² ¾ÅÍ²
-- ============================================
-- 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29
-- ============================================
-- Ò»Ìõ ¶þÌõ ÈýÌõ ËÄÌõ ÎåÌõ ÁùÌõ ÆßÌõ °ËÌõ ¾ÅÌõ

--0x41 转转麻将 红中

--广东麻将
--0x31 白
--0x41 红
--51 发

--61 东
--71 南
--81 西 

--91北
--
local function getVariety(card)
    return bit.brshift(card, 4)
end

--
-- 
local function getValue(card) 
    return bit.band(card, 0x0F)
end


local tb_feng={
    -- ori code 
    -- [0x31]="49",--白
    -- [0x41]="65_1",
    -- [0x51]="81",
    -- [0x61]="97",
    -- [0x71]="113",
    -- [0x81]="129",
    -- [0x91]="145"

    -- M @Jhao 2017-1-24
    [0x31] = "97",
    [0x32] = "113",
    [0x33] = "129",
    [0x34] = "145",
}

local tb_jian = {
    [0x41] = "65",
    [0x42] = "81",
    [0x43] = "50",
}

local tb_hu={}

function tb_hu:getCardData(card)

	if not card then
        --todo
        printError("card is null")
        return {};
    end

    local t={}
    card=tonumber(card)

    if self._game_type==3 and card==65 then --转转麻将的红中
        --todo
         --todo
        t.type_color="feng"
        t.val=65
        return t;
    end

    if self._game_type==4 and tb_feng[card]  then --广东麻将的特殊牌
        --todo
        t.type_color="feng"
        if tb_feng[card]=="65_1" then
            --todo
            t.val=65
        else
            t.val=tonumber(tb_feng[card])
        end
   
        return t;
    end

    if tb_feng[card] then
        --todo
        t.type_color = "feng"           -- folder name 
        t.val = tonumber(tb_feng[card])
        return t;
    end

    local color= getVariety(card)
    local val_=card--getValue(card);

    local cardMsg = string.format("card:%x", card)
    print("@@@@@@@@@@@@Jhao test getCardData----:", cardMsg)

    -- Add @Jhao. 默认中发白牌值处理
    local mahjongType = getVariety(card)
    if mahjongType == 3 then
        t.type_color = "feng"           -- folder name 
        t.val = tonumber(tb_feng[val_]) -- img res name
        return t
    elseif mahjongType == 4 then
        t.type_color = "feng"           -- folder name 
        t.val = tonumber(tb_jian[val_]) -- img res name
        return t
    end

    local colorStr=color_[color]
    t.type_color=colorStr
    t.val=tonumber(val_)

    return t
end


function tb_hu:setranInfo(info,game_type)
	self._handle=info
	self._game_type=game_type
end

function tb_hu:getSeatid(uid)
	 for k1,v1 in pairs(self._handle) do
    	if v1.uid==uid then
    		--todo
    		return k1,v1
    	end
    end

end
--
function tb_hu:getHuInfoStr(v)
	local tb_huData={}
	local result_str="" 
	local fan_total
	local hucard



    --是否胡了
    local ifhu = v.isHu
    if ifhu == 1 and v.hu then
    	local hucontent=v.hu
   		
        --获取胡的牌型
        local cardkind = hucontent.paiType
        local cardkind_arr = cct.split(cardkind, ",")
        if #cardkind_arr > 0 then
            for k,v in pairs(cardkind_arr) do
            	local card_kind_name
            	if self._game_type==1 then
            		--todo
            		card_kind_name = CARD_TYPE[tonumber(v)]
            	elseif self._game_type==2 then
            		card_kind_name = card_hu_type_cs[tonumber(v)]
            	end
                --local card_kind_name = CARD_TYPE[tonumber(v)]
                --dump(card_kind_name, "-----card_kind_name-----")
                if card_kind_name then
                    result_str = result_str .. card_kind_name .. " "
                end
            end
        end

        --记录总番数
        fan_total = hucontent.totalFan
        tb_huData.fanshu_data=fan_total;

        --记录点炮的用户id
        local paoid

        --胡的类型
        local hutype = hucontent.huType
        if hutype == 1 then --平胡

            local pinghu = hucontent.fangPao

            --是否杠上炮
            if pinghu.isGangShangPao == 1 then 
                result_str = result_str .. "杠上炮 "
            end

            --是否抢杠胡
            if pinghu.isQiangGangHu == 1 then
                result_str = result_str .. "抢杠胡 "
            end

            --是否海底炮
            if pinghu.isHaiDiPao == 1 then
                result_str = result_str .. "海底炮 "
            end

            --记录胡的牌
            hucard = pinghu.card

            --显示接炮
            --记录谁点炮
            paoid = pinghu.fromUId
            local seat_id,userInfo=self:getSeatid(paoid)
            local nickName = userInfo.nick
            result_str = result_str .. "接" .. nickName .. "的炮 "

   
            

        else 
            --自摸
            result_str = result_str .. "自摸 "

            local zimo = hucontent.ziMo
            if zimo then
            	--todo
            	--记录胡的牌
	            hucard = zimo.card

	            --是否杠上花
	            if zimo.isGangShangHua == 1 then
	                result_str = result_str .. "杠上花 "
	            end

	        else
	        	error("胡的数据异常");
            end
            

        end

        --------------------------------------------------这是四川麻将的-----
        --是否天胡
        if hucontent.isTianHu == 1 then
            result_str = result_str .. "天胡 "
        end

        --是否地胡
        if hucontent.isDiHu == 1 then
            result_str = result_str .. "地胡 "
        end

        --是否扫底胡
        if hucontent.isSaoDiHu == 1 then
            result_str = result_str .. "扫底胡 "
        end

        --是否金钩胡
        if hucontent.isJinGouHu == 1 then
            result_str = result_str .. "金钩胡 "
        end

        --根
        if hucontent.genCount ~= nil then
            if tonumber(hucontent.genCount) > 0 then
                result_str = result_str .. "根X" .. tostring(hucontent.genCount) .. " "
            end
        end

        --显示是第几个胡
	    local huOrder = hucontent.huOrder

        if huOrder ~= nil then
    
      		tb_huData.huOrder=huOrder --第几个胡
        end

        -----------------------------------------------------------------------------------


        --------------------------------------------这是长沙麻将
        if hucontent.isQiShouHu and hucontent.isQiShouHu==1  then
        	--todo
        	result_str=result_str.."起手胡 "
        end

        if hucontent.isDaHu and hucontent.isDaHu==1  then
        	--todo
        	result_str=result_str.."大胡 "
        end
        ----------------------------------------------------------------

        

        

    else
    	--没胡的
        tb_huData.fanshu_data=0
    end

    local seat_id,userInfo=self:getSeatid(v.uid)




    if self._game_type==1 then
    	--todo
    	print("game_type is ",userInfo.score)
    	tb_huData.score=userInfo.score
    elseif self._game_type==2 then
    	tb_huData.score=v.win
    end
    
    tb_huData.seat_id=seat_id

    --是否点炮
    if v.isFangPao==1 then
        result_str = result_str .. "点炮 "
    end

    ------------------------------这是四川麻将的-----------------------------
    --显示明杠数（刮风）
    local mingGangNum = v.mingGangCount
    if mingGangNum and mingGangNum > 0 then
        result_str = result_str .. "刮风X" .. tostring(mingGangNum) .. " "
    end

    --显示暗杠数（下雨）
    local anGangNum = v.anGangCount
    if anGangNum and anGangNum > 0 then
        result_str = result_str .. "下雨X" .. tostring(anGangNum) .. " "
    end

    --是否花猪
    if v.isHuaZhu == 1 then
        result_str = result_str .. "花猪 "
    end

    --是否大叫
    if v.isDaJiao == 1 then
        result_str = result_str .. "大叫"
    end

    tb_huData.card_info=result_str
    ----------------------------------------------------------------------

    return tb_huData

	
end



function tb_hu:getHandles(handle)

    local result = {}

    local mingoran = nil  --1
    
    --
    if bit.band(handle, 0x010) == 0x010 then
        result['pg'] = 0x010
        mingoran     = 0
    end

    --
    if bit.band(handle,  0x008) ==  0x008 then
        result['p'] = 0x008
    end

    --
    if bit.band(handle,  0x040) ==  0x040 then
        result['h'] = 0x040
    end

    --
    if bit.band(handle,   0x080) ==   0x080 then
        result['h'] =  0x080
    end

    --
    if bit.band(handle, 0x100) ==    0x100 then
        result['h'] =   0x100
    end

    --
    if bit.band(handle, 0x200) ==    0x200 then
        result['g'] =   0x200
        mingoran    =   1
    end

    --
    if bit.band(handle, 0x400) ==    0x400 then
        result['g'] =   0x400
        mingoran    =   0
    end

    --
    if bit.band(handle, 0x800) ==    0x800 then
        result['h'] =   0x800
    end

    if bit.band(handle, 0x001)==0x001 then --右吃
        --todo
        result["rc"]=0x001
    end

    if bit.band(handle, 0x002)==0x002 then --中吃
        --todo
        result["cc"]=0x002
    end

    if bit.band(handle, 0x004)==0x004 then --左吃
        --todo
        result["lc"]=0x004
    end

    if bit.band(handle, 0x10000)==0x10000 then --左吃
        --todo
        result["ting"]=0x10000
    end
    -- if bot.bind(handle,0x2000)=0x2000 then --漫游 要
    -- 	--todo
    -- 	result["my"]=0x2000
    -- end

    return result,mingoran
end


return tb_hu
