mrequire("timer.timer_action")

StartEffectTimer = class("StartEffectTimer",timer.timer_action.TimerAction)

function StartEffectTimer:_do_after_init()

end

function StartEffectTimer:perform_timer_action(current_time)
	print("------StartEffectTimer")
end