Logic_Manager = class("Logic_Manager")
mrequire("account.account_operator")
-----------------------------------------------------------------------------
--本来如果是代码是从大厅开始重构的话，打算在这个类处理一些和原生代码的交互。
--
--现在只在这里使用外部的数据初始化话account对象
------------------------------------------------------------------------------
function Logic_Manager:ctor()

end

function Logic_Manager:initialize()

    --创建用户，初始化用户数据内容
    account.account_operator.init_account_object(USER_INFO["icon_url"],USER_INFO["nick"],0,USER_INFO["sex"],USER_INFO["uid"])

end

