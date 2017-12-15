mrequire("control.control_manager")

manager = nil

function do_after_init()
	manager = control.control_manager.ControlManager.new()
	manager:initialize()
	print("---------function----do_after_init---")
end

function initialize()
	--xpcall(do_after_init, function() print(debug.traceback()) end, 33)
	do_after_init()
end