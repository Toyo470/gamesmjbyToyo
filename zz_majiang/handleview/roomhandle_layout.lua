mrequire("handleview.roomhandle_template")

dump(handleview.roomhandle_template.roomhandle_Template,"myzengtao")




HandleLayout = class("HandleLayout", handleview.roomhandle_template.roomhandle_Template)

local zz_majiangServer = require("zz_majiang.zz_majiangServer")

function HandleLayout:_do_after_init()
	self.roomhandle_Text_1:setString("邀请微信好友")
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

	require("hall.common.ShareLayer"):showShareLayer("红中麻将，房号：" .. USER_INFO["invote_code"], "https://a.mlinks.cc/AK3b", "url", share_content)
end

function HandleLayout:click_roomhandle_room_btn_quit_room_event()
	-- local account_object = account.get_player_account()
	-- local account_id = account_object:get_account_id()
	-- if tostring(account_id) == tostring(USER_INFO["group_owner"]) then
	-- 	tips.show_tips("dissolve_title","dissolve_content",handler(self,self.dissolve_room),handler(self,self.cancal))
	--else
	tips.show_tips("dissolve_title","dissolve_content_ex",handler(self,self.dissolve_room),handler(self,self.cancal))
	--end

	 --local result_tbl = {}
	-- --result_tbl['p'] = 1
	 --require("zz_majiang.pengresult"):show_handle_result(0,result_tbl)
	-- require("zz_majiang.pengresult"):show_handle_result(1,result_tbl)
	-- require("zz_majiang.pengresult"):show_handle_result(2,result_tbl)
	-- require("zz_majiang.pengresult"):show_handle_result(3,result_tbl)
	 -- require("zz_majiang.pengresult"):show_hu_result(0)
	 -- require("zz_majiang.pengresult"):show_hu_result(1)
	 -- require("zz_majiang.pengresult"):show_hu_result(2)
	 -- require("zz_majiang.pengresult"):show_hu_result(3)
	-- local layout_object = layout.reback_layout_object("room_handleresult")
	-- layout_object:reset_result_hu(1)
	-- layout_object:reset_result_hu(2)
	-- layout_object:reset_result_hu(0)
	-- layout_object:reset_result_hu(3)
end

--返回解散房间
function HandleLayout:dissolve_room()
	layout.hide_layout("tips")
	layout.hide_layout("roomhandle")
	
	zz_majiangServer:c2s_request_dissove()
end

--取消回调
function HandleLayout:cancal()
	-- body
	layout.hide_layout("tips")
end