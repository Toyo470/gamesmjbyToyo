
function parser_time_difference(time_elapse)
	require "cal"
	local current_time = cal.manager:get_current_time()
	local sub_time = (time_elapse - current_time)
	if sub_time < 0 then
		return ""
	end
	
	local time_str = ""
	local day = int(sub_time / 86400)
	if day > 0 then
		time_str = time_str + string.format("%.2d:",day)
	end
	
	local hour = int((sub_time - day * 86400) / 3600)
	if hour > 0 then
		time_str = time_str + string.format("%.2d:",hour)
	end
	
	local minute = int((sub_time - day * 86400 - hour * 3600) / 60)
	if minute > 0 then
		time_str = time_str + string.format("%.2d:" % minute)
	end
	
	local second = int((sub_time - day * 86400 - hour * 3600 - minute * 60))
	time_str = time_str + string.format("%.2d:" % second)
	
	if string.len(time_str) > 0 then
		return string.sub(time_str,1,-2)
	else
		return ""
	end
	
end