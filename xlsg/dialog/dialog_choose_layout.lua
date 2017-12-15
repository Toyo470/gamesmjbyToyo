mrequire("dialog.dialog_choose_template")

DialogChoose = class("DialogChoose", dialog.dialog_choose_template.dialog_choose_Template)

function DialogChoose:_do_after_init()
	self.icon_dict = {self.dialog_choose_txt1,
					  self.dialog_choose_txt2,
					  self.dialog_choose_txt3,
	                  self.dialog_choose_txt4,
	}
-- self.dialog_choose_btn_not,
	self.touch_icon_dict = {self.dialog_choose_btn_1,
							self.dialog_choose_btn_2,
							self.dialog_choose_btn_3,
							self.dialog_choose_btn_4,
							}
	self.icon_qiang_dict = {self.dialog_choose_btn_qiang,self.dialog_choose_btn_buqiang}
end


function DialogChoose:resetdata( game_dialog )
	-- body
	local option_style = game_dialog["option_style"] or 0
	if tonumber(option_style) == 0 then
		return 
	end

	if tonumber(option_style) == 1 then
		self.dialog_choose_qiangzang:setVisible(true)
		self.dialog_choose_qiangfeng:setVisible(false)

		for index,content in pairs(self.icon_qiang_dict) do
			local icon = self.icon_qiang_dict[index]
			if icon ~= nil then
				icon.icon_index = index
				-- icon:setTouchEnabled(false)
				icon:onClick(handler(self, self.click_choose_btn))
			end
		end

	elseif tonumber(option_style) == 2 then --加倍
		self.dialog_choose_qiangzang:setVisible(false)
		self.dialog_choose_qiangfeng:setVisible(true)

		local option_content = game_dialog["option_content"] or {}
		for index,content in pairs(option_content) do
			local option_content = content[1]
			-- local option_x = content["option_x"] or  content[2]
			-- local option_y = content["option_y"] or  content[3]
			--option_y = 200
			local icon = self.icon_dict[index]
			if icon ~= nil then
				-- icon[1]:setPositionX(tonumber(option_x))
				-- icon[1]:setPositionY(tonumber(option_y))
				icon:setString(option_content)
			end

			icon = self.touch_icon_dict[index]
			icon.icon_index = index
			icon:onClick(handler(self, self.click_choose_btn))
			-- icon:setTouchEnabled(false)
		end

		self.dialog_choose_btn_not.icon_index = -1
	    -- self.dialog_choose_btn_not:setTouchEnabled(false)
		self.dialog_choose_btn_not:onClick(handler(self, self.click_choose_btn))

	end
end


function DialogChoose:click_choose_btn(target)
	-- body
	local index = tonumber(target.icon_index)

	if index == -1 then
		self:hide_layout()
		return
	end

	index = index - 1 --C++和lua的数组索引不同
	print("--click_choose_btn-------------------------",index)

	self:hide_layout()

	local data_tbl = {}
	local ZZ_Send = require("xlsg.ZZ_Send")
	data_tbl["option_index"] = index
	ZZ_Send:send(mprotocol.H2G_ACCOUNT_GAME_DIALOG_CHOOSE,data_tbl)

end