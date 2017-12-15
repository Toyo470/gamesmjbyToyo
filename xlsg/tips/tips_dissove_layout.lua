-- module(..., package.seeall)

mrequire("tips.tips_dissove_template")
TipsDissoveLayout = class("TipsDissoveLayout", tips.tips_dissove_template.tips_dissove_Template)

function TipsDissoveLayout:_do_after_init()
	self.sure_callback = nil
	self.cancel_callback = nil
	self.time_out = 60 * 5
end

function TipsDissoveLayout:reset_confirm_content( title,content )
	-- body
	title = title or ""
	content = content or ""
	self.tips_dissove_tips_title:setString(title)
	self.tips_dissove_tips_content:setString(content)
end

-- function TipsDissoveLayout:reset_player_content( content1,content2,content3 )
-- 	-- body
-- 	content1 = content1 or ""
-- 	content2 = content2 or ""
-- 	content3 = content3 or ""
-- 	self.tips_dissove_tips_player1:setString(content1)
-- 	self.tips_dissove_tips_player2:setString(content2)
-- 	self.tips_dissove_tips_player3:setString(content3)

-- end



function TipsDissoveLayout:reset_confirm_sure_callback( sure_callback )
	-- body
	self.tips_dissove_tips_btn_sure:setVisible(true)
	self.sure_callback = sure_callback

	if sure_callback == nil then
		self.tips_dissove_tips_btn_sure:setVisible(false)
	end
end

function TipsDissoveLayout:reset_confirm_cancel_callback( cancel_callback )
	-- body
	self.tips_dissove_tips_btn_cancel:setVisible(true)
	self.cancel_callback = cancel_callback

	if cancel_callback == nil then
		self.tips_dissove_tips_btn_cancel:setVisible(false)
	end
end

function TipsDissoveLayout:click_tips_dissove_tips_btn_sure_event()
	if self.sure_callback ~= nil then
		self.sure_callback()
	end
end

function TipsDissoveLayout:click_tips_dissove_tips_btn_cancel_event()
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
end

function TipsDissoveLayout:set_show_update_flag(show_update_flag )
	-- body
	show_update_flag = show_update_flag or false

	self:set_update_flag(show_update_flag)
	self.tips_dissove_time:setVisible(show_update_flag)
	self.tips_dissove_clock_2:setVisible(show_update_flag)
end

function TipsDissoveLayout:update(dt)
	if self.time_out < 0 then
		self.tips_dissove_time:setVisible(false)
		self:click_tips_dissove_tips_btn_sure_event()
		self:set_update_flag(false)
		self.tips_dissove_clock_2:setVisible(false)
		return
	end

	self.time_out = self.time_out - dt
	local str,_ = math.modf(self.time_out)
	self.tips_dissove_time:setString(tostring(str))

end