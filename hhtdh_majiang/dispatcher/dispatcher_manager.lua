DispatcherManager = class("DispatcherManager")

function DispatcherManager:ctor()
	self.dispatcher_dict = {}
end

function DispatcherManager:release()
	self.dispatcher_dict = {}
end

function DispatcherManager:register_protocol_callback(msg_id, callback)
	self.dispatcher_dict[msg_id] = callback
end

function DispatcherManager:deal_protocol_callback(msg_id, json_str)
	local callback = self.dispatcher_dict[msg_id]
	if callback == nil then
		print(string.format("****************************************************!!!!!!ERROR msg_id(%s) is not define",msg_id))
		return
	end
	local msg_data = extern.parser_json_data(json_str)
	
	callback(msg_id,msg_data)
end