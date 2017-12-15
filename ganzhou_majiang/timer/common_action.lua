mrequire("timer.timer_action")

CommonTimer = class("CommonTimer",timer.timer_action.TimerAction)

function CommonTimer:perform_timer_action(current_time)
	if self.callback ~= nil then
		if self.object ~= nil then
			self.callback(self.object,self.param)
		else
			self.callback(self.param)
		end
	end
end

function CommonTimer:set_timer_callback(callback,param,object)
	self.callback = callback
	self.param = param
	self.object = object
end

function CommonTimer:_do_after_init()
	self.callback = nil
	self.param = nil
	self.object = nil
end