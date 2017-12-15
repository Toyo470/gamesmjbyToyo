mrequire("account.account_object")

AccountManager = class("AccountManager")

function AccountManager:ctor()
	self.account_object = nil
end

function AccountManager:initialize()
	--account.account_dispatcher.init_dispatcher()
end
	
function AccountManager:release()
	if self.account_object == nil then
		return
	end
	
	self.account_object = nil
end
	
function AccountManager:create_account_object()
	if self.account_object ~= nil then
		self:release() 
	end
	
	local account_object = account.account_object.AccountObject.new()
	account_object:initialize()
	
	self.account_object = account_object
	return account_object
end

function AccountManager:get_account_object()
	return self.account_object
end

