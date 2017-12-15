mrequire("handleview.roomhandle_template")
HandleLayout = class("HandleLayout", handleview.roomhandle_template.roomhandle_Template)

local ZZ_Send = require("xlsg.ZZ_Send")

function HandleLayout:_do_after_init()
	--self.roomhandle_Text_1:setString("邀请微信好友")
end

function HandleLayout:click_roomhandle_room_btn_invite_event()
	--按照传入的分隔符，切割字符串
local function LuaSplit(str, split_char)  
    if str == "" or str == nil then   
        return {};  
    end  
    local split_len = string.len(split_char)  
    local sub_str_tab = {};  
    local i = 0;  
    local j = 0;  
    while true do  
        j = string.find(str, split_char,i+split_len);--从目标串str第i+split_len个字符开始搜索指定串  
        if string.len(str) == i then   
            break;  
        end  
  
  
        if j == nil then  
            table.insert(sub_str_tab,string.sub(str,i));  
            break;  
        end;  
  
  
        table.insert(sub_str_tab,string.sub(str,i,j-1));  
        i = j+split_len;  
    end  
    return sub_str_tab;  
end  

	local config_arr = LuaSplit(USER_INFO["gameConfig"], " ")
	--dump(config_arr, "-----share_content-----")
	local share_content = ""
	for k,v in pairs(config_arr) do
		if v ~= "" then
			share_content = share_content .. v .. ","
		end
	end
	share_content = string.sub(share_content, 1, string.len(share_content) - 1)
	print("share_content-----------",share_content)

	require("hall.common.ShareLayer"):showShareLayer("三公，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", share_content)
            
end

function HandleLayout:click_roomhandle_room_btn_quit_room_event()
	tips.show_tips("dissolve_title","dissolve_content_ex",handler(self,self.dissolve_room),handler(self,self.cancal))
end

--返回解散房间
function HandleLayout:dissolve_room()
	layout.hide_layout("tips")
	layout.hide_layout("roomhandle")
	
	local data_tbl = {}
    ZZ_Send:send(mprotocol.H2G_DISSOLVE_ROOM,data_tbl)
end

--取消回调
function HandleLayout:cancal()
	-- body
	layout.hide_layout("tips")
end