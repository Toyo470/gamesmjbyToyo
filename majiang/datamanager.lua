--
-- Author: chen
-- Date: 2016-06-28-20:02:02
--
local datamanager=class("datamanager")

function datamanager:ctor()
end

--这个用来处理比赛场重登后的人数轮请求
function datamanager:match_game_http(level)
        cct.createHttRq({
            url=HttpAddr .. "/game/matchGame",
            date={
                gameId=4,
            },
            type_="GET",
            callBack= function(data)
            self:http_match_callback(data,level)
         end
        })
end

function datamanager:http_match_callback(data,level)
	print("http_match_callback",level)
	level = 61
   -- dump(data)
    data.netData=json.decode(data.netData)
    if data.netData.returnCode~="0" then
        return;
    end

    dump(data.netData)

    for _,room in pairs(data.netData.data.roomList) do 
    	if room.level == level then

    		local playerGoons = room.playerGoons
    		
    		local tbRank = {}
	        for j,v in pairs(playerGoons) do
	            tbRank[j] = v.playerCount
	        end
	        print("level",level)
	        dump(tbRank,"tbRank")
        	require("majiang.ddzSettings"):addMatchRank(level,tbRank)
 			local rankinfo = require("majiang.ddzSettings"):getMatchLevelRankInfo(level)
 			require("majiang.MatchSetting"):setRankInfo(rankinfo)
    		break;
    	end
    end

end

--这个用来保存标示是自由场1还是比赛场2
--需要在重登时标示
local majiang_game_mode = 0
function datamanager:get_game_mode()
    return data_manager
end
function datamanager:set_game_mode(mode)
    data_manager = mode
end


return datamanager

