-- module(..., package.seeall)

mrequire("tips.tips_template")
TipsLayout = class("TipsLayout", tips.tips_template.tips_Template)

function TipsLayout:_do_after_init()
	self.sure_callback = nil
	self.cancel_callback = nil
end

function TipsLayout:reset_confirm_content( title,content )
	-- body
	title = title or ""
	content = content or ""
	self.tips_title:setString(title)
	self.tips_content:setString(content)
end

function TipsLayout:reset_confirm_sure_callback( sure_callback )
	-- body
	self.sure_callback = sure_callback
end

function TipsLayout:reset_confirm_cancel_callback( cancel_callback )
	-- body
	self.cancel_callback = cancel_callback
end

function TipsLayout:click_tips_btn_sure_event(sure_callback)
	if self.sure_callback ~= nil then
		self.sure_callback()
	end
end

function TipsLayout:click_tips_btn_cancel_event(cancel_callback)
	if self.cancel_callback ~= nil then
		self.cancel_callback()
	end
end

function TipsLayout:set_only_sure()
	-- body
	self.tips_btn_cancel:setVisible(false)
	self.tips_btn_sure:setPositionX(480)
end