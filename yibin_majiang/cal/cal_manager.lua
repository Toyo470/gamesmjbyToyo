mrequire("os")

CalManager = class()

function CalManager:ctor()
	self.deviation_time = 0
	self.fight_protocol_time = 0
end

function CalManager:initialize()
end

function CalManager:set_deviation_time(deviation_time)
	self.deviation_time = deviation_time
end

function CalManager:get_deviation_time()
	return self.deviation_time
end	
	
function CalManager:get_clock_time()
	return os.clock() + self.deviation_time
end	

function CalManager:get_local_clock_time()
	return os.clock()
end	
	
function CalManager:get_local_os_time()
	return os.time()
end	
	
function CalManager:get_current_time()
	return os.time() + self.deviation_time
end

function CalManager:get_current_clock_time()
	local lock_time = os.clock() + self.deviation_time
	return  string.format("%.2f", lock_time)
end
	
function CalManager:get_local_time()
	return os.date("%Y %m %d %H %M %S", self:get_current_time())
end

function CalManager:get_local_target_time(target_time)
	return os.date("%Y %m %d %H %M %S %w", target_time)
end