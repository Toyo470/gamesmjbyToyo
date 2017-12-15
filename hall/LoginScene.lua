local loginInstance = loginInstance or nil

local LoginScene = class("LoginScene", function() 
	return display.newScene("LoginScene")
end)



function LoginScene:ctor()
	self.scene = cc.CSLoader:createNode("hall/Login.csb")
    -- local notice = cc.Label:createWithTTF("抵制不良游戏 拒绝盗版游戏 谨防上当受骗 适度游戏益脑 沉迷游戏伤身 合理安排时间 享受健康生活","res/fonts/fzcy.ttf",20):addTo(self.scene)
    -- notice:setPosition(cc.p(480, 15))
    -- notice:setColor(cc.c3b(255,254,10))
    local androidVer=cc.Label:createWithTTF("","res/fonts/fzcy.ttf",20):addTo(self.scene)  --显示版本号
    androidVer:setName("androidVer")
    androidVer:setPosition(cc.p(820,45))
    local banbenhao=cc.UserDefault:getInstance():getStringForKey("androidVer","")
    androidVer:setString("版本号："..banbenhao)
    --用户协议选项框
    self.check_bx = self.scene:getChildByName("check_bx")

    self.agreement_bt = self.scene:getChildByName("agreement_bt")
    --微信登陆按钮
	self.login_bt = self.scene:getChildByName("login_bt")
    if isiOSVerify then
        -- 隐藏勾选框
        self.check_bx:setVisible(false)
        -- 隐藏用户协议
        self.agreement_bt:setVisible(false)
        -- 因此微信登陆按钮
        self.login_bt:setVisible(false)
        -- self.login_bt:setPosition(self.login_bt:getPosition().x + 200, self.login_bt:getPosition().y)

        --快速登陆按钮
        local button = ccui.Button:create()
        button:setTouchEnabled(true)
        button:setAnchorPoint(0.5,0.5)
        button:setPosition(self.login_bt:getPosition().x, self.login_bt:getPosition().y - 50)
        button:loadTextures("hall/hall/fast_button.png", nil, nil)
        button:addTo(self.scene)
        button:addTouchEventListener(

            function(sender,event)

                --触摸结束
                if event == TOUCH_EVENT_ENDED then

                    bm.isQuickLogin = "1"

                    --隐藏登陆界面并获取用户数据
                    SCENENOW["scene"]:initFinished()

                    -- require("hall.hallScene"):initFinished()

                end

            end

        )
    end

	self:initListeners()
end

function LoginScene:onEnter()
end

function LoginScene:onExit()
end

function LoginScene:show()

    --开启心跳检测,这里他们要求loginLayer隐藏的时候开始检测心跳。
    --loginLayer显示的时候不检测心跳包

    --printError("LoginScene")

    bm.checknetworking = false


    if device.platform=="android" then
        if SCENENOW["name"]~="hall.loginGame" then
            --todo
            require("app.HallUpdate"):enterHall2();
        end
    end

    local loginLayer = SCENENOW["scene"]:getChildByName("loginLayer")

    if loginLayer then
        --todo
        loginLayer:removeFromParent()
    end

    --todo
    loginInstance = LoginScene:new()
    loginInstance.scene:setName("loginLayer")
    loginInstance.scene:setLocalZOrder(90000)
    SCENENOW["scene"]:addChild(loginInstance.scene)
    --设置当前不是快速登陆
    bm.isQuickLogin = "0"
    bm.isLoginScene = 1

end

function LoginScene:initListeners()

	local login_bt_t = self.login_bt
	local check_bx_t = self.check_bx
	local agreement_bt_t = self.agreement_bt
    login_bt_t:setTouchEnabled(true)
    check_bx_t:setEnabled(true)
	local function touchButtonEvent(sender, event)

        if event == TOUCH_EVENT_ENDED then
        	
            if sender == login_bt_t then
                print("wxLogin test")

    --             login_bt_t:setColor(cc.c3b(129, 129, 129))
				-- login_bt_t:setTouchEnabled(false)
    --             check_bx_t:setEnabled(false)
                local userdefine=cc.UserDefault:getInstance()

                if device.platform == "windows" then

                    phpLogined = 0
                    require("hall.hallScene"):initFinished()
                
                else

                    if isTaoAndroid then
                        local userinfo=userdefine:getStringForKey("USER_INFO", "")
                        if userinfo~="" then
                            --todo
                            userinfo=cct.unserialize(userinfo)
                            USER_INFO["uid"]=userinfo.uid
                            USER_INFO["gold"]=userinfo.gold
                            USER_INFO["cardCount"]=userinfo.cardCount
                            USER_INFO["nick"]=userinfo.nick
                            USER_INFO["headUrl"]=userinfo.headUrl
                            USER_INFO["sex"]=userinfo.sex
                            USER_INFO["type"] = "P"
                            SCENENOW["scene"].login:PHPLogin(USER_INFO["uid"])
                        else

                
                            SCENENOW["scene"]:wxLogin()
                        end
                    else
                        
                         local sigs = {}
                        cct.getDateForApp("wxLogin",{},"V")
                    end
                 
                end

            end
            --打开音乐
      
            --打开音效
            if sender == agreement_bt_t then
                print("agreement test")
                local am_msg = "广州星晋网络科技有限公司《789广东麻将用户协议》\n    在此特别提醒用户认真阅读本《协议》中各条款内容，包括免除或者限制本公司责任的免责条款及用户的权利限制。请您审阅并选择接受或不接受本《协议》（未成年人应在法定监护人陪同下审阅）。用户对本协议的接受即受本公司与用户之间全部协议的约束，包括接受本公司对服务条款随时所做的任何修改。这些条款可由本公司随时更新，且无须另行通知。修改后的用户协议一旦在协议发布页面上公布即有效代替原来的用户协议，用户可随时登录官网查阅最新用户协议。\n如果不同意所改动的内容，用户可以主动取消或立即停止使用本公司提供的的网络服务。如果用户继续享用本公司提供的网络服务，则视为接受本公司对服务条款的变动。\n    本《用户协议》分为两部分，第一部分是文化部根据《网络游戏管理暂行规定》（文化部令第49号）制定的《网络游戏服务格式化协议必备条款》，第二部分是大程网络根据《中华人民共和国著作权法》、《中华人民共和国合同法》、《著作权行政处罚实施办法》、《网络游戏管理暂行规定》等国家法律法规拟定的《789广东麻将》《用户协议》条款。内容如下：\n第一部分 文化部网络游戏服务格式化协议必备条款\n根据《网络游戏管理暂行规定》（文化部令第49号），文化部制定《网络游戏服务格式化协议必备条款》。甲方为网络游戏运营企业，乙方为网络游戏用户。\n1.账号注册\n1.1 乙方承诺以其真实身份注册成为甲方的用户，并保证所提供的个人身份资料信息真实、完整、有效，依据法律规定和必备条款约定对所提供的信息承担相应的法律责任。\n1.2 乙方以其真实身份注册成为甲方用户后，需要修改所提供的个人身份资料信息的，甲方应当及时、有效地为其提供该项服务。\n2.用户账号使用与保管\n2.1 根据必备条款的约定，甲方有权审查乙方注册所提供的身份信息是否真实、有效，并应积极地采取技术与管理等合理措施保障用户账号的安全、有效；乙方有义务妥善保管其账号及密码，并正确、安全地使用其账号及密码。任何一方未尽上述义务导致账号密码遗失、账号被盗等情形而给乙方和他人的民事权利造成损害的，应当承担由此产生的法律责任。\n2.2乙方对登录后所持账号产生的行为依法享有权利和承担责任。\n2.3 乙方发现其账号或密码被他人非法使用或有使用异常的情况的，应及时根据甲方公布的处理方式通知甲方，并有权通知甲方采取措施暂停该账号的登录和使用。\n2.4 甲方根据乙方的通知采取措施暂停乙方账号的登录和使用的，甲方应当要求乙方提供并核实与其注册身份信息相一致的个人有效身份信息。\n2.4.1 甲方核实乙方所提供的个人有效身份信息与所注册的身份信息不一致的，应当及时采取措施暂停乙方账号的登录和使用。\n2.4.2 甲方违反2.4.1款项的约定，未及时采取措施暂停乙方账号的登录和使用，因此而给乙方造成损失的，应当承担其相应的法律责任。\n2.4.3 乙方没有提供其个人有效身份证件或者乙方提供的个人有效身份证件与所注册的身份信息不一致的，甲方有权拒绝乙方上述请求。\n2.5 乙方为了维护其合法权益，向甲方提供与所注册的身份信息相一致的个人有效身份信息时，甲方应当为乙方提供账号注册人证明、原始注册信息等必要的协助和支持，并根据需要向有关行政机关和司法机关提供相关证据信息资料。\n3.服务的中止与终止\n3.1乙方有发布违法信息、严重违背社会公德、以及其他违反法律禁止性规定的行为，甲方应当立即终止对乙方提供服务。\n3.2乙方在接受甲方服务时实施不正当行为的，甲方有权终止对乙方提供服务。该不正当行为的具体情形应当在本协议中有明确约定或属于甲方事先明确告知的应被终止服务的禁止性行为，否则，甲方不得终止对乙方提供服务。\n3.3乙方提供虚假注册身份信息，或实施违反本协议的行为，甲方有权中止对乙方提供全部或部分服务；甲方采取中止措施应当通知乙方并告知中止期间，中止期间应该是合理的，中止期间届满甲方应当及时恢复对乙方的服务。\n3.4 甲方根据本条约定中止或终止对乙方提供部分或全部服务的，甲方应负举证责任。 \n4.用户信息保护\n4.1 甲方要求乙方提供与其个人身份有关的信息资料时，应当事先以明确而易见的方式向乙方公开其隐私权保护政策和个人信息利用政策，并采取必要措施保护乙方的个人信息资料的安全。\n4.2未经乙方许可甲方不得向任何第三方提供、公开或共享乙方注册资料中的姓名、个人有效身份证件号码、联系方式、家庭住址等个人身份信息，但下列情况除外：\n4.2.1 乙方或乙方监护人授权甲方披露的；\n4.2.2 有关法律要求甲方披露的；\n4.2.3 司法机关或行政机关基于法定程序要求甲方提供的；\n4.2.4 甲方为了维护自己合法权益而向乙方提起诉讼或者仲裁时；\n4.2.5 应乙方监护人的合法要求而提供乙方个人身份信息时。\n第二部分 《789广东麻将》《用户协议》条款\n789麻将中心服务条款\n1、释义\n本服务条款系由用户与本公司之间，关于用户注册、使用《789广东麻将》相关服务所订立的协议。\n请于成为《789广东麻将》用户之前，详细阅读本服务条款的所有内容，当您点选同意按钮或进入《789广东麻将》中即视为同意并接受本服务条款的所有规范并愿受其约束。\n2、帐号清理规则\n为确保游戏运行顺畅，减轻服务器的压力，官方有权对长期未登录游戏的低级账号做出不定期的清理。以下是清理账号的基本规则，如有特殊情况，会另作说明。\n清理账号基本规则：1个月或以上时间未登录游戏，等级在10级或以下，无任何社会关系（婚姻关系，公会关系等），无充值记录，身上无点券。\n\n3、帐号管理规则\n（1）.使用外 挂进行游戏者，官方有权永久封禁其帐号。 \n（2）.辱骂、威胁官方人员者，官方有权永久封禁其帐号。 \n（3）.如果你对当前游戏帐号的发展情况不满意，你可以选择放弃该帐号并重新注册帐号。\n（4）.冒充官方人员或点券商人在游戏中行骗者，发布虚假信息者，官方有权永久封禁其帐号。 \n（5）.玩家账号个人资料修改必须联系客服提供详细的账号资料，玩家私下交易账号，官方不予修改，并且有权对账号进行冻结！ \n（6）. 提高安全防范意识，妥善保管帐号和密码，因帐号被盗造成的游戏损失，都不会得到游戏管理团队任何形式的补偿由玩家自行负责。 \n（7）.所有注册帐号只可用于玩家进行正常的游戏，不得用于对游戏进行恶意攻击或破坏，官方有权对任何不符合游戏规则的帐号进行封号和删除。\n （8）.游戏中的所有数据均属于本公司所有，任何玩家不得进行私自交易，如果玩家因私下进行帐号或物品交易所导致的损失，官方不做任何补偿。\n（9）.同一IP在同一区服，登陆数量最高限 制为10个。如果过登陆数量超过10个，我们将对所有帐号做出冻结帐号处理，情况较轻的玩家给予冻结帐号7天处理，情节严重的永久冻结帐号。\n（10）.玩家游戏时使用的角色名等自定义命名均不得使用违反国家法规、带侮辱性的词语或官方人员名字，不得故意注册和其他玩家相似的名字，如有违反，官方有权强制要求其更改或冻结帐号。\n（11）. 账号密码标志着账号的使用权。玩家账号使用的密码不得以任何理由给予另外一个玩家。若玩家将密码透露给第三方，意味着将账号的使用权也转让给了第三方，由此产生的账号以及游戏道具损失由玩家自行负责！ \n>>>>请各位玩家注意账号安全 谨防受骗<<<<\n4、游戏行为准则\n（1）.玩家必须保管好自己的帐号和密码，由于玩家个人的原因导致帐号和密码泄密而造成的后果均将由该玩家自行承担。\n（2）.同意并按照《789广东麻将》运营团队发布、变更和修改的本玩家规则及其他规则，接受并使用我们的产品和服务，玩家不得通过不正当的手段或其他不公平的手段使用我们的产品和服务或参与我们活动。\n（3）.玩家需对自己帐号中的所有活动和事件负责。须遵守有关互联网信息发布的有关法律、法规及通常适用的互联网一般道德和礼仪的规范，玩家将自行承担其所发布的信息内容的责任。特别提醒玩家不得发布下列内容：\n1）反对宪法所确定的基本原则的；\n2）危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一的；\n3）损害国家荣誉和利益的；\n4）煽动民族仇恨、民族歧视，破坏民族团结的；\n5）破坏国家宗教政策，宣扬邪教和封建迷信的；\n6）散布谣言，扰乱社会秩序，破坏社会稳定的；\n7）散布淫秽、色 情、赌 博、暴力、凶杀、恐怖或者教唆犯罪的；\n8）侮辱或者诽谤他人，侵害他人合法权益的；\n9）含有法律、行政法规禁止的其他内容的。\n10）侵犯任何第三者的知识产权，版权或公众私人 权利的。\n11）违反人文道德、风俗习惯的。（如：在游戏内恶意刷屏和辱骂他人。）\n12）任何形式的未经《789广东麻将》运营团队允许的广告。\n13）煽动玩家，造谣生事。\n以上条约，若有玩家违反其中一条，官方都有权利对其帐号进行封禁。\n5、游戏漏洞规则\n1.《789广东麻将》运营团队鼓励玩家报告游戏中出现的问题和漏洞，一经证实将有机会获得奖励；\n2.所有利用游戏中的漏洞进行非法谋利或恶意攻击的行为被严格禁止，一经发现，帐号将被删除；\n6、辅助软件规则\n1.本游戏禁止采用非官方提供的游戏辅助工具，由此带来的任何后果由玩家自己负责；\n2.除市面传统网络浏览器外，任何用户帐号都无权使用任何可能影响到游戏程序运行稳定或游戏发展的外部软件来进行游戏，不得进行任何使服务器负载过量或造成技术超载的行为。一经发现，《789广东麻将》运营团队保留对采用游戏辅助软件进行游戏的帐号的处置权；\n7、处罚规则\n（1）.警告：即对违规玩家进行警告。\n（2）.封号：即封闭违规玩家的帐号；\n（3）.删号：即删除违规玩家的帐号；\n（4）.玩家对惩罚如有解释或意见，可以联系公司客服人员进行说明，管理员有权根据实际情况决定是否更改处罚和回复结果。\n8、服务中断、停止和变更的说明\n发生下列情形之一时，《789广东麻将》运营团队有权中断、停止或变更其所提供的服务，对于因此而产生的困扰、不便或损失，运营方不承担任何责任：\n (1).定期检查维护，软硬件更新等，即暂停服务，运营方将尽快完成维修、维护工作。\n (2).服务器遭到任何形式的破坏，无法正常运作。\n (3).网络线路或其它导致玩家通过Internet连接至游戏服务器的动作发生滞碍等情形。\n (4).自然灾害等不可抗力的因素。\n (5).在紧急情况之下为维护国家 安全或其它会员及第三者人身安全时。\n (6).发生突发性软硬件设备与电子通信设备故障时。\n9、游戏规则的解释、变更和添加\n本规则的解释、效力及适用以中华人民共和国法律为依据。如果本协议的任何内容与法律相抵触，以法律规定为准。\n此前提下，《789广东麻将》运营团队保留解释、更改和添加游戏规则的权利，规则解释、更改和添加自公布之时起生效。请用户时刻关注本规则。\n"
            	require("hall.GameCommon"):showAgreement(true,am_msg)
            end
        end
    end
    self.login_bt:addTouchEventListener(touchButtonEvent)
    -- self.check_bx:addTouchEventListener(touchButtonEvent)
    self.agreement_bt:addTouchEventListener(touchButtonEvent)

    -- self.check_bx:onEvent(function(event)
    -- 		if event.name == "selected" then
    --             print("highlight true")
    --             login_bt_t:setEnabled(false)
    --             check_bx_t:setSelectedState(false)
    --         else
    --             print("highlight false")
    --             login_bt_t:setEnabled(true)
    --             check_bx_t:setSelectedState(true)
    --         end
    -- 	end)

    self.check_bx:addEventListener(function(sender, eventType)
        if eventType == 0 then
            print("highlight true")
            login_bt_t:setColor(cc.c3b(255, 255, 255))
            login_bt_t:setTouchEnabled(true)
            check_bx_t:setSelectedState(true)
        else
            print("highlight false")
            login_bt_t:setColor(cc.c3b(129, 129, 129))
            login_bt_t:setTouchEnabled(false)
            check_bx_t:setSelectedState(false)
        end
    end)
end

function LoginScene:init()

    dump("", "-----登录界面初始化-----")

    local login_bt = self.scene:getChildByName("login_bt")
    local check_bx = self.scene:getChildByName("check_bx")

    login_bt:setColor(cc.c3b(255, 255, 255))
    login_bt:setTouchEnabled(true)
    check_bx:setEnabled(true)

end





return LoginScene
