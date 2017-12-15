mrequire("cal")
mrequire("timer.common_action")

TimerManager = class("TimerManager")

function TimerManager:ctor()
	self.timer_action_list = {}
	
	self.frame_timer_action_list = {}
end

function TimerManager:clear_frame_timer_action_list()
	self.frame_timer_action_list = {}
end

function TimerManager:clear_timer_action_list()
	self.timer_action_list = {}
end

function TimerManager:register_timer_func(time_elapse,func,param,object)
	local common_timer = timer.common_action.CommonTimer.new()
	common_timer:set_timer_callback(func,param,object)
	
	local current_time = cal.manager:get_local_clock_time()
	local action_list = {time_elapse + current_time, common_timer,time_elapse}
	table.insert(self.frame_timer_action_list,action_list)
	
	table.sort(self.frame_timer_action_list, function (n1, n2)
		return n1[1] < n2[1]  -- compare the grades
	end
	)
end

function TimerManager:register_timer_func_by_count(time_elapse,func,param,object)
	local common_timer = timer.common_action.CommonTimer.new()
	common_timer:set_timer_callback(func,param,object)
	local action_len = table.getn(self.frame_timer_action_list)
	local current_time = cal.manager:get_local_clock_time()
	local action_list = {time_elapse*action_len + current_time, common_timer,time_elapse}
	table.insert(self.frame_timer_action_list,action_list)
	
	table.sort(self.frame_timer_action_list, function (n1, n2)
		return n1[1] < n2[1]  -- compare the grades
	end
	)
end

function TimerManager:register_timer_action(time_elapse, timer_action,looper)
	local current_time = cal.manager:get_current_time()
	looper = looper or 1
	local action_list = {time_elapse + current_time, timer_action,time_elapse,looper}
	table.insert(self.timer_action_list,action_list)
		
	table.sort(self.timer_action_list, function (n1, n2)
		return n1[1] < n2[1]  -- compare the grades
	end
	)
	
end

function TimerManager:match_time_action()
	local current_time = cal.manager:get_current_time()
	for _,action_data in pairs(self.timer_action_list) do
		action_data[1] = current_time + action_data[3]
	end
	
	table.sort(self.timer_action_list, function (n1, n2)
		return n1[1] < n2[1]  -- compare the grades
	end
	)
end

function TimerManager:remove_timer_action(timer_action)
	for key, cur_action_table in pairs(self.timer_action_list) do
		local index_time_action = cur_action_table[2] 
		if timer_action == index_time_action then
			table.remove(self.timer_action_list,key)
			return true
		end
	end
	return false
end

function TimerManager:perform_all_frame_timer()
	local current_time = cal.manager:get_local_clock_time()
	for index,timer_data in pairs(self.frame_timer_action_list) do
		local time_out = timer_data[1]
	end
	
	local timer_index = 1
	while(true) do
		if timer_index <= table.getn(self.frame_timer_action_list) then
			local timer_action_data = self.frame_timer_action_list[timer_index]
			local time_out = timer_action_data[1]
			local time_action = timer_action_data[2]
			if time_out <= current_time then
				table.remove(self.frame_timer_action_list,1)
				time_action:perform_timer_action(current_time)
				timer_index = timer_index + 1
			else
				return
			end
		else
			return
		end
	end
end

function TimerManager:perform_all_timer()
	local current_time = cal.manager:get_current_time()
	
	for index,timer_data in pairs(self.timer_action_list) do
		local time_out = timer_data[1]
	end
	
	local timer_index = 1
	while(true) do
		if timer_index <= table.getn(self.timer_action_list) then
			local timer_action_data = self.timer_action_list[timer_index]
			local time_out = timer_action_data[1]
			local time_action = timer_action_data[2]
			local time_elapse = timer_action_data[3]
			local looper = timer_action_data[4]
			if time_out <= current_time then
				if looper == 1 then
			 		table.remove(self.timer_action_list,timer_index)
			 		timer_index =  timer_index - 1
			 	elseif looper > 1 then
			 		self.timer_action_list[timer_index] = {current_time + time_elapse,time_action,time_elapse,looper-1}			 		
			 	else
			 		self.timer_action_list[timer_index] = {current_time + time_elapse,time_action,time_elapse,looper}			 											 
			 	end
				time_action:perform_timer_action(current_time)
			else
				return
			end
		else
			return
		end
		timer_index =  timer_index + 1
	end
end

function TimerManager:judge_contain_timer_action (timer_action)
	for key, cur_action_table in pairs(self.timer_action_list) do
		local index_time_action = cur_action_table[2] 
		if timer_action == index_time_action then			
			return true
		end
	end
	return false
end