mrequire("renovator.renovator_manager")
mrequire("macros.macros_manager")
mrequire("account.account_operator")
mrequire("layout.layout_manager")
mrequire("ui.ui_manager")
mrequire("account.account_manager")
mrequire("define.define_manager")
mrequire("httprq.httprq_manager")
mrequire("logic.logic_manager")
mrequire("control.control_manager")
mrequire("dispatcher.dispatcher_manager")
mrequire("zzroom.room_manager")
mrequire("music.music_manager")
mrequire("handleview")
mrequire("tips")
mrequire("timer.timer_manager")
mrequire("cal.cal_manager")
mrequire("game.game_manager")

ControlManager = class("ControlManager")

function ControlManager:ctor()
	self.manager_dict = {}
	self.is_finish_load = false
	self.last_time = 0
end
		
function ControlManager:get_control_manager(manager_name)
	return self.manager_dict[manager_name]
end

function ControlManager:release()
	for manager_name,_manager in pairs(self.manager_dict) do
		if _manager and _manager.release then
			_manager:release()
		end
	end

	self.manager_dict = {}
	self.is_finish_load = false
	self.last_time = 0
end

function ControlManager:initialize()
	if self.is_finish_load == true then
		return
	end
	self.is_finish_load = true
	
	self:init_manager_table()
	
	--self:init_account_data()
end

function ControlManager:update(dt)
	layout.manager:update_layout(dt)
	--ui.manager:update()
	
	self.last_time = self.last_time + dt
	if self.last_time >= 5 then
		self.last_time = 0
		self:update_1000ms()
	end

end

function ControlManager:update_1000ms()
	--print("-----------------------update_1000ms-------------------------")
	-- storage.manager:update()
	-- activity.manager:update()
	-- timer.manager:perform_all_timer()
	timer.manager:perform_all_timer()
end
	
function ControlManager:init_account_data()
	account.account_operator.init_account_object()
end
	
function ControlManager:init_manager_table()

	-- math.randomseed(os.time())
	--管理器统一都设有initialize函数算了，强制要求

	macros.manager = macros.macros_manager.MacrosManager.new()
	self.manager_dict["macros"] = macros.manager
	macros.manager:initialize()

	renovator.manager = renovator.renovator_manager.RenovatorManager.new()
    self.manager_dict["renovator"] = renovator.manager
    renovator.manager:initialize()


    define.manager = define.define_manager.DefineManager.new()
    self.manager_dict["define"] = define.manager
    define.manager:initialize()

	ui.manager = ui.ui_manager.UiManager.new()
	self.manager_dict["ui"] = ui.manager
	ui.manager:initialize()

    layout.manager = layout.layout_manager.LayoutManager.new()
    self.manager_dict["layout"] = layout.manager
	layout.manager:initialize()
 	
	account.manager = account.account_manager.AccountManager.new()
    self.manager_dict["account"] = account.manager
	account.manager:initialize()

	httprq.manager = httprq.httprq_manager.HttpRq_Manager.new()
	self.manager_dict["httprq"] = httprq.manager
	httprq.manager:initialize()


	dispatcher.manager = dispatcher.dispatcher_manager.DispatcherManager.new()
	self.manager_dict["dispatcher"] = dispatcher.manager


	zzroom.manager = zzroom.room_manager.RoomManager.new()
	self.manager_dict["zzroom"] = zzroom.manager
	zzroom.manager:initialize()


	music.manager = music.music_manager.MusicManager.new()
	self.manager_dict["music"] = music.manager
	music.manager:initialize()

	cal.manager = cal.cal_manager.CalManager.new()
	self.manager_dict["cal"] = cal.manager
	cal.manager:initialize()

	timer.manager = timer.timer_manager.TimerManager.new()
	self.manager_dict["timer"] = timer.manager
	
	game.manager = game.game_manager.GameManager.new()
	self.manager_dict["game"] = game.manager
	--mrequire("game.game_timer")
	--local game_timer = game.game_timer.StartEffectTimer.new()
	--timer.manager:register_timer_action(5,game_timer)
	print("-----ControlManager:init_manager_table----------------")

end

function ControlManager:init_logic()
	logic.manager = logic.logic_manager.Logic_Manager.new()
	self.manager_dict["logic"] = logic.manager
	logic.manager:initialize()

	print("----------------------init_manager_table---------------------------")
end

function ControlManager:reload(manager_name)
	local manager = self.manager_dict[manager_name]
	if manager == nil then
		return false
	end
	
	manager:initialize()
	return true
end