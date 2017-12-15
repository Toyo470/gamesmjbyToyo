mrequire("base.cobject_base")

AccountObject = class("AccountObject",base.cobject_base.CObjectBase)

function AccountObject:ctor()
	print("----------------AccountObject:ctor()---------------")
	AccountObject.super.ctor(self);
	self.is_save = true
	self.module_name = "AccountObject"
	self.account_session = nil
end

function AccountObject:get_account_unique_code()
  return self:get_attribute(keys.ACCOUNT_UNIQUE_CODE)
end

function AccountObject:set_account_unique_code(unique_code)
	self:set_attribute(keys.ACCOUNT_UNIQUE_CODE,unique_code)
end

function AccountObject:_do_after_init()
	--以前这里是初始化一些itemruler之类的东西
end
	
function AccountObject:decrease_nolimit_account_int_value(key, decrease_value)
	local cur_value = self:get_attribute_number_value(key)
	cur_value = cur_value - decrease_value
	self:set_attribute(key, cur_value)
	return true
end

function AccountObject:get_account_session()
	return self.account_session
end

function AccountObject:get_account_daily()
	return self:get_attribute(keys.ACCOUNT_DAILY)
end

function AccountObject:get_account_cookie()
	return self:get_attribute(keys.ACCOUNT_COOKIE)
end

function AccountObject:get_account_month()
	return self:get_attribute(keys.ACCOUNT_MONTH)
end

function AccountObject:get_hero_ruler()
	return self:get_attribute(keys.HERO_RULER)
end

function AccountObject:get_pet_ruler()
	return self:get_attribute(keys.PET_RULER)
end

function AccountObject:get_item_ruler()
	return self:get_attribute(keys.ITEM_RULER)
end

function AccountObject:get_account_gold()
	return self:get_attribute_number_value(keys.ACCOUNT_GOLD)
end

function AccountObject:set_account_gold(account_gold)
	return self:set_attribute(keys.ACCOUNT_GOLD, account_gold)
end

function AccountObject:get_account_diamond()
	return self:get_attribute_number_value(keys.ACCOUNT_DIAMOND)
end

function AccountObject:set_account_diamond(account_diamond)
	return self:set_attribute(keys.ACCOUNT_DIAMOND, account_diamond)
end

function AccountObject:get_account_id()
	return self:get_attribute_number_value(keys.ACCOUNT_ID)
end

function AccountObject:set_account_id(account_id)
	self:set_attribute(keys.ACCOUNT_ID,account_id)
end

function AccountObject:get_account_score()
	return self:get_attribute_number_value(keys.ACCOUNT_SCORE)
end

function AccountObject:set_account_score(account_score)
	self:set_attribute(keys.ACCOUNT_SCORE,account_score)
end

function AccountObject:get_account_wintimes()
	return self:get_attribute_number_value(keys.ACCOUNT_WINTIMES)
end

function AccountObject:set_account_wintimes(account_wintimes)
	self:set_attribute(keys.ACCOUNT_WINTIMES,account_wintimes)
end

function AccountObject:get_account_losetimes()
	return self:get_attribute_number_value(keys.ACCOUNT_LOSETIMES)
end

function AccountObject:set_account_losetimes(account_losetimes)
	self:set_attribute(keys.ACCOUNT_LOSETIMES,account_losetimes)
end

function AccountObject:get_account_chip()
	return self:get_attribute_number_value(keys.ACCOUNT_CHIP)
end

function AccountObject:set_account_chip(account_chip)
	self:set_attribute(keys.ACCOUNT_CHIP,account_chip)
end

function AccountObject:after_decrease_attribute_number_value(key,value,source)
	account.account_observer.after_decrease_account_object(key,value)
end

function AccountObject:get_account_name()
	return self:get_attribute_string_value(keys.ACCOUNT_NAME)
end

function AccountObject:set_account_name(name)
	self:set_attribute(keys.ACCOUNT_NAME,name)
end


function AccountObject:get_account_iconrul()
	return self:get_attribute_string_value(keys.ACCOUNT_ICONRUL)
end

function AccountObject:set_account_iconrul(account_iconrul)
	self:set_attribute(keys.ACCOUNT_ICONRUL,account_iconrul)
end


function AccountObject:get_account_sex()
	return self:get_attribute_number_value(keys.ACCOUNT_SEX)
end

function AccountObject:set_account_sex(account_sex)
	self:set_attribute(keys.ACCOUNT_SEX,account_sex)
end

