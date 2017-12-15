
TimerAction = class()

function TimerAction:perform_timer_action(current_time)
end

function TimerAction:initialize()
	self:_do_after_init()
end

function TimerAction:_do_after_init()
end

function TimerAction:perform_timer_action(current_time)
	-- body
end