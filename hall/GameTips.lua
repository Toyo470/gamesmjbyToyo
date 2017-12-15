local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local GameTips  = class("GameTips")

--title  提示文字
--code   处理标识
--bShowButton  0:不显示按钮；1：全部显示；2：显示取消；3：显示确定: 4: 全部隐藏
--msg    显示详情
--data   处理数据
-- okCallback   确定按钮回调

--提示

function GameTips:showTips(title,code,bShowButton,msg,data,layout, okCallback)
    --  layout 黑屏能否点击remove当前页面    0 不能  其他能
    require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()
    print(layout,"sssssssssssssssssssss")
    if code == "agree_disbandGroup" or code == "cs_disbandGroup" or code == "cs_request_disbandGroup" or code == "cs_disbandGroup_success" or code == "kwx_disbandGroup" or code == "kwx_request_disbandGroup"
        or code == "disbandGroup" or code == "request_disbandGroup" or code == "disbandGroup_success" or code == "disbandGroup_fail" or code == "kwx_liangdao_remaid" or code == "szkwx_disbandGroup" or code == "szkwx_request_disbandGroup" or code == "xykwx_disbandGroup" or code == "xykwx_request_disbandGroup" then
        
        self:showDisbandTips(title,code,bShowButton,msg,data)
        return

    end

    -- printError("show tips")
    if bShowButton then
        print("show button state:"..tostring(bShowButton))
    end
    bShowButton = bShowButton or 0
    msg = msg or ""
    data = data or ""

    if SCENENOW["scene"] then

        --释放之前的
        local s = SCENENOW["scene"]:getChildByName("layer_tips")
        if s then
            s:removeSelf()
        end
        s = cc.CSLoader:createNode("hall/tips/LayerTips_new.csb")
        --s:getChildByName("tips_back_1"):setTexture("hall/tips/tips_back.png")
        s:setName("layer_tips")
        SCENENOW["scene"]:addChild(s,99998)

        local layer = s:getChildByName("tips_back_1")
        local txt = layer:getChildByName("txt_msg")
        if txt then
             txt:setString(title)
        --   txt:enableOutline(cc.c4b(58,35,10,255),1)
        end

        local lbTitle = layer:getChildByName("txt_title")
        if lbTitle then
            lbTitle:enableOutline(cc.c4b(58,35,10,255),1)
        end

        local msg_tt = layer:getChildByName("msg_tt")
        msg_tt:setString(msg)
        if code == "request_disbandGroup" or code == "cs_request_disbandGroup" or code == "agree_disbandGroup" then
            msg_tt:setTextHorizontalAlignment(0)
        end

        local btnSubmit = layer:getChildByName("btn_submit")
        btnSubmit:setScale(0.8)

        local btnCancel = layer:getChildByName("btn_cancel")
        btnCancel:setScale(0.8)

        local btn_sure =  layer:getChildByName("btn_sure")
        btn_sure:setScale(0.8)

        if bShowButton == 0 then
            btn_sure:setVisible(true)
            btnCancel:setVisible(false)
            btnSubmit:setVisible(false)
        else
            btn_sure:setVisible(false)
        end

        if bShowButton == 1 then--全部显示
            -- btnSubmit:setVisible(true)
            -- btnSubmit:setPosition(cc.p(263.61,72.01))
            -- btnCancel:setVisible(true)
            -- btnCancel:setPosition(cc.p(71.74,72.01))
            -- btn_sure:setVisible(false)

        elseif bShowButton == 2 then--只显示取消按钮

            btnSubmit:setVisible(false)
            btnSubmit:setPosition(cc.p(960,58))

            btnCancel:setVisible(true)
            btnCancel:setPosition(cc.p(333.0, 102.00))

            btn_sure:setVisible(false)

        elseif bShowButton == 3 then--只显示确定按钮

            btnSubmit:setVisible(true)
            btnSubmit:setPosition(cc.p(333.0, 102.00))

            btnCancel:setVisible(false)
            btnCancel:setPosition(cc.p(960,58))

            btn_sure:setVisible(false)

        elseif bShowButton == 4 then
             btnSubmit:setVisible(false)
             btnCancel:setVisible(false)
             btn_sure:setVisible(false)

        end

        local function touchEvent(sender, event)

            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.7)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(0.8)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(0.8)

                require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

                --现在去（确定）
                if sender == btnSubmit then

                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end

                    -- 确定按钮回调
                    if okCallback then
                        okCallback()
                    end

                    if code then
                        --比赛奖励报名
                        if code == "GameAwardPool" then
                            self:HandleGameAwardPool()
                        elseif code == "change_money" then
                            require("hall.GameCommon"):gRecharge()
                        elseif code == "change_money2chips" then --兑换筹码之前
                            SCENENOW["scene"]:callBackTips("change_money2chips", 1)
                            require("hall.GameCommon"):gRecharge()
                            -- require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        elseif code == "reloadBull" then
                            --退出大厅游戏
                            require("hall.GameCommon"):gExitGame()
                        elseif code == "loginGameFailed" then
                            if USER_INFO["enter_mode"] == 0 then
                                require("hall.GameUpdate"):enterGame(USER_INFO["current_code"])
                            else
                                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                            end
                        elseif code == "kick_off" then
                            --请请出游戏后的操作
                            
                            -- if USER_INFO["enter_mode"] == 0 then
                            --     require("hall.GameCommon"):gExitGame()
                            -- else
                            --     require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                            -- end

                            --返回到登录页
                            require("hall.LoginScene"):show()


                        elseif code == "change_chip" then
                            require("hall.GameCommon"):showChange(true)
                        elseif code == "network_disconnect" then
                            -- if USER_INFO["enter_mode"] > 0 then
                            --     require("ddz.PlayVideo"):stopVideo()
                            -- end
                            local next = require("src.app.scenes.MainScene").new()
                            SCENENOW["scene"] = next
                            SCENENOW["name"] = "app.scenes.MainScene"
                            display.replaceScene(next)

                        elseif code == "GameupdateError" then
                            --更新游戏出错处理
                            -- require("hall.GameUpdate"):updateGame(data.url, data.version, data.gid, data.code)

                        elseif code == "tohall" then
                            -- 确定按钮回调
                            if okCallback then
                                okCallback()
                            else
                                require("hall.GameTips"):enterHall()
                            end
                            
                        elseif code == "cs_disbandGroup" then
                            --申请解散组局
                            if CSMJ_CONTROLLER then
                                --todo
                                CSMJ_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end
                        elseif code == "cs_request_disbandGroup" then
                            --同意解散组局
                            if CSMJ_CONTROLLER then
                                --todo
                                CSMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end
                        elseif code == "disbandGroup" then
                            --申请解散组局
                            require("majiang.scenes.MajiangroomServer"):C2G_CMD_DISSOLVE_ROOM()

                        elseif code == "request_disbandGroup" then
                            --同意解散组局
                            require("majiang.scenes.MajiangroomServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(1)

                        elseif code == "disbandGroup_success" then
                            --解散组局成功
                            require("majiang.ddzSettings"):setEndGroup(2)
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        elseif code == "cs_disbandGroup_success" then
                            --解散组局成功
                            -- require("majiang.ddzSettings"):setEndGroup(2)
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        elseif code == "disbandGroup_fail" then
                            --解散组局失败

                        elseif code == "reloadGame" then
                            --重连游戏
                            require("hall.groudgamemanager"):join_freegame(USER_INFO["uid"],data["inviteCode"],data["activityId"],true)

                        elseif code == "updateGame" then
                            --更新游戏，当更新游戏出错时用
                            require("hall.groudgamemanager"):updateGameInJoinGame(data["url"], data["version"], data["gid"], data["code"])

                        end

                    end
                end

                --下次吧（取消）
                if sender == btnCancel then

                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end

                    if code then
                        --比赛奖励报名
                        if code == "reloadBull" then
                            --退出大厅游戏
                            require("hall.GameCommon"):gExitGame()
                        elseif code == "loginGameFailed" then
                            if USER_INFO["enter_mode"] == 0 then
                                require("hall.GameUpdate"):enterGame(USER_INFO["current_code"])
                            else
                                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                            end
                        elseif code == "kick_off" then

                            --被请出游戏后的操作

                            -- if USER_INFO["enter_mode"] == 0 then
                            --     require("hall.GameCommon"):gExitGame()
                            -- else
                            --     require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                            -- end

                            --返回到登录页
                            require("hall.LoginScene"):show()


                        elseif code == "change_chip" then--退出组局
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        elseif code == "change_money2chips" then--退出组局
                            SCENENOW["scene"]:callBackTips("change_money2chips", 0)
                            -- require("ddz.ddzServer"):CLI_LOGOUT_ROOM()
                            -- require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        elseif code == "error" then
                            --退出大厅游戏
                            if USER_INFO["enter_mode"] == 0 then
                                require("hall.GameCommon"):gExitGame()
                            else
                                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                            end
                        elseif code == "network_disconnect" then
                            --退出大厅游戏
                            if USER_INFO["enter_mode"] == 0 then
                                require("hall.GameCommon"):gExitGame()
                            else
                                require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                            end
                        elseif code == "cs_disbandGroup" then
                            --申请退出组局

                        elseif code == "cs_request_disbandGroup" then
                            --拒绝解散组局
                            if CSMJ_CONTROLLER then
                                --todo
                                CSMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end
                        elseif code == "disbandGroup" then
                            --申请退出组局

                        elseif code == "request_disbandGroup" then
                            --拒绝解散组局
                            require("majiang.scenes.MajiangroomServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(0)

                        elseif code == "disbandGroup_success" then
                            --解散组局成功
                            require("majiang.ddzSettings"):setEndGroup(2)
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        elseif code == "cs_disbandGroup_success" then
                            --解散组局成功
                            -- require("majiang.ddzSettings"):setEndGroup(2)
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        elseif code == "disbandGroup_fail" then
                            --解散组局失败

                        elseif code == "reloadGame" then
                            --重连游戏
                            require("hall.groudgamemanager"):exitFreeGame(USER_INFO["uid"],data["inviteCode"])

                        elseif code == "updateGame" then
                            --更新游戏，当更新游戏出错时用
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                            
                        end

                    end
                elseif  sender == btn_sure then
                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end          
                end
            end
        end

        btnSubmit:addTouchEventListener(touchEvent)
        btnCancel:addTouchEventListener(touchEvent)
        btn_sure:addTouchEventListener(touchEvent)

        local layEffect = s:getChildByName("Panel_1")
        if layEffect then 
            layEffect:setTouchEnabled(true)  
            layEffect:addTouchEventListener(function(sender,event)
                if event==2 then
                    if layout~=0 then
                        if SCENENOW["scene"]:getChildByName("layer_tips") then
                            SCENENOW["scene"]:removeChildByName("layer_tips")
                        end
                    end
                    --比赛奖励报名
                    if code == "reloadBull" then
                        --退出大厅游戏
                        require("hall.GameCommon"):gExitGame()
                    elseif code == "loginGameFailed" then
                        if USER_INFO["enter_mode"] == 0 then
                            require("hall.GameUpdate"):enterGame(USER_INFO["current_code"])
                        else
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        end
                    elseif code == "kick_off" then
                        --退出大厅游戏
                        if USER_INFO["enter_mode"] == 0 then
                            require("hall.GameCommon"):gExitGame()
                        else
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        end
                    elseif code == "change_chip" then--退出组局
                        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                    elseif code == "change_money2chips" then--退出组局
                        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                    elseif code == "error" then
                        --退出大厅游戏
                        if USER_INFO["enter_mode"] == 0 then
                            require("hall.GameCommon"):gExitGame()
                        else
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        end
                    elseif code == "network_disconnect" then
                        --退出大厅游戏
                        if USER_INFO["enter_mode"] == 0 then
                            require("hall.GameCommon"):gExitGame()
                        else
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        end
                    end
                end
            end)

        end
    end
end

--解散功能专用弹出框
function GameTips:showDisbandTips(title,code,bShowButton,msg,data)

    require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()

    if bShowButton then
        print("show button state:"..tostring(bShowButton))
    end
    bShowButton = bShowButton or 0
    msg = msg or ""
    data = data or ""

    if SCENENOW["scene"] then

        --释放之前的
        local s = SCENENOW["scene"]:getChildByName("layer_tips")
        if s then
            s:removeSelf()
        end

        s = cc.CSLoader:createNode("hall/tips/LayerTips_disband.csb")
        --s:getChildByName("tips_back_1"):setTexture("hall/tips/tips_back.png")
        s:setName("layer_tips")
        SCENENOW["scene"]:addChild(s,99998)

        local layer = s:getChildByName("tips_back_1")
        local txt = layer:getChildByName("txt_msg")
        if txt then
             txt:setString(title)
        end

        local lbTitle = layer:getChildByName("txt_title")
        if lbTitle then
            lbTitle:enableOutline(cc.c4b(58,35,10,255),1)
        end

        local msg_tt = layer:getChildByName("msg_tt")
        msg_tt:setString(msg)
        if code == "request_disbandGroup" or code == "cs_request_disbandGroup" or code == "agree_disbandGroup" or code == "ddz_request_disbandGroup" or code == "niuniu_request_disbandGroup" then
            msg_tt:setTextHorizontalAlignment(0)
        end

        local btnSubmit = layer:getChildByName("btn_submit")
        btnSubmit:setScale(0.8)

        local btnCancel = layer:getChildByName("btn_cancel")
        btnCancel:setScale(0.8)

        local btn_sure =  layer:getChildByName("btn_sure")
        btn_sure:setScale(0.8)

        if bShowButton == 0 then
            btn_sure:setVisible(true)
            btnCancel:setVisible(false)
            btnSubmit:setVisible(false)
        else
            btn_sure:setVisible(false)
        end

        if bShowButton == 1 then--全部显示

        elseif bShowButton == 2 then--只显示取消按钮

            btnSubmit:setVisible(false)
            btnSubmit:setPosition(cc.p(960,58))

            btnCancel:setVisible(true)
            btnCancel:setPosition(cc.p(232.0, 150.00))

            btn_sure:setVisible(false)

        elseif bShowButton == 3 then--只显示确定按钮

            btnSubmit:setVisible(true)
            btnSubmit:setPosition(cc.p(232.0, 150.00))

            btnCancel:setVisible(false)
            btnCancel:setPosition(cc.p(960,58))

            btn_sure:setVisible(false)

        elseif bShowButton == 4 then
             btnSubmit:setVisible(false)
             btnCancel:setVisible(false)
             btn_sure:setVisible(false)

        end

        local function touchEvent(sender, event)

            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.7)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(0.8)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(0.8)

                require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

                --现在去（确定）
                if sender == btnSubmit then

                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end

                    if code then
                        if code == "kwx_liangdao_remaid" then
                            --todo
                            if KWX_CONTROLLER then
                                --todo
                                KWX_CONTROLLER:replyLiangdaoRemaid(true)
                            end
                        elseif code == "cs_disbandGroup" then
                            --申请解散组局
                            if CSMJ_CONTROLLER then
                                --todo
                                CSMJ_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "cs_request_disbandGroup" then
                            --同意解散组局
                            if CSMJ_CONTROLLER then
                                --todo
                                CSMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end
                        elseif code == "kwx_disbandGroup" then
                            --申请解散组局
                            if KWX_CONTROLLER then
                                --todo
                                KWX_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "kwx_request_disbandGroup" then
                            --同意解散组局
                            if KWX_CONTROLLER then
                                --todo
                                KWX_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end
                        elseif code == "szkwx_disbandGroup" then
                            --申请解散组局
                            if SZKWX_CONTROLLER then
                                --todo
                                SZKWX_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "szkwx_request_disbandGroup" then
                            --同意解散组局
                            if SZKWX_CONTROLLER then
                                --todo
                                SZKWX_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end
                        elseif code == "xykwx_disbandGroup" then
                            --申请解散组局
                            if XYKWX_CONTROLLER then
                                --todo
                                XYKWX_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "xykwx_request_disbandGroup" then
                            --同意解散组局
                            if XYKWX_CONTROLLER then
                                --todo
                                XYKWX_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end
                        elseif code == "disbandGroup" then
                            --申请解散组局
                            require("majiang.scenes.MajiangroomServer"):C2G_CMD_DISSOLVE_ROOM()

                        elseif code == "request_disbandGroup" then
                            --同意解散组局
                            require("majiang.scenes.MajiangroomServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(1)

                        elseif code == "disbandGroup_success" then
                            --解散组局成功
                            require("majiang.ddzSettings"):setEndGroup(2)
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                        elseif code == "cs_disbandGroup_success" then
                            --解散组局成功
                            -- require("majiang.ddzSettings"):setEndGroup(2)
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                        elseif code == "disbandGroup_fail" then
                            --解散组局失败



                        -- 牛牛解散相关
                        elseif code == "niuniu_disbandGroup" then
                            --申请解散组局
                            require("niuniu.niuniuNamal.NiuniuroomServer"):C2G_CMD_DISSOLVE_ROOM()

                        elseif code == "niuniu_request_disbandGroup" then
                            --同意解散组局
                            dump("同意解散组局", "-----牛牛同意解散组局-----")

                            require("niuniu.niuniuNamal.NiuniuroomServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(1)

                        elseif code == "niuniu_disbandGroup_success" then
                            --解散组局成功
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])



                        --斗地主相关
                        elseif code == "ddz_disbandGroup" then
                            --申请解散组局
                            dump("申请解散组局", "-----斗地主-----")

                            dump(bm.Room.UserInfo, "-----斗地主-----")

                            require("ddz.ddzServer"):C2G_CMD_DISSOLVE_ROOM()

                        elseif code == "ddz_request_disbandGroup" then
                            --同意解散组局

                            dump("同意解散组局", "-----斗地主同意解散组局-----")

                            require("ddz.ddzServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(1)



                       --推倒胡相关
                        elseif code == "tdh_disbandGroup" then
                            --申请解散组局
                            dump("申请解散组局", "-----推倒胡-----")

                            if TDHMJ_CONTROLLER then
                                --todo
                                TDHMJ_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "tdh_request_disbandGroup" then
                            --同意解散组局
                            if TDHMJ_CONTROLLER then
                                TDHMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end



                     --168麻将相关
                        elseif code == "YKMJ_disbandGroup" then
                            --申请解散组局
                            dump("申请解散组局", "-----推倒胡-----")

                            if YKMJ_CONTROLLER then
                                --todo
                                YKMJ_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "YKMJ_request_disbandGroup" then
                            --同意解散组局
                            if YKMJ_CONTROLLER then
                                YKMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end


                     --海南麻将相关
                        elseif code == "HNMJ_disbandGroup" then
                            --申请解散组局
                            dump("申请解散组局", "-----推倒胡-----")

                            if HNMJ_CONTROLLER then
                                --todo
                                HNMJ_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "HNMJ_request_disbandGroup" then
                            --同意解散组局
                            if HNMJ_CONTROLLER then
                                HNMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end


                      --红中麻将相关
                        elseif code == "ZZMJ_disbandGroup" then
                            --申请解散组局
                            dump("申请解散组局", "-----推倒胡-----")

                            if ZZMJ_CONTROLLER then
                                --todo
                                ZZMJ_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "ZZMJ_request_disbandGroup" then
                            --同意解散组局
                            if ZZMJ_CONTROLLER then
                                ZZMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end

                        --广东麻将
                        elseif code == "gd_disbandGroup" then
                            require("gd_majiang.gd_majiangServer"):c2s_request_dissove()
                        --红中麻将
                        elseif code == "hz_disbandGroup" then
                            require("zz_majiang.zz_majiangServer"):c2s_request_dissove()



                        --广东麻将相关
                        elseif code == "GDMJ_disbandGroup" then
                            --申请解散组局
                            dump("申请解散组局", "-----推倒胡-----")

                            if GDMJ_CONTROLLER then
                                --todo
                                GDMJ_CONTROLLER:C2G_CMD_DISSOLVE_ROOM()
                            end

                        elseif code == "GDMJ_request_disbandGroup" then
                            --同意解散组局
                            if GDJ_CONTROLLER then
                                GDMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(1)
                            end



                        --跑得快申请解散
                        elseif code == "pdk_disbandGroup" then
                            --申请解散组局
                            dump("申请解散组局", "-----跑得快-----")

                            dump(bm.Room.UserInfo, "-----跑得快-----")

                            require("pdk.pdkServer"):C2G_CMD_DISSOLVE_ROOM()


                        elseif code == "pdk_disbandGroup_success" then
                            --解散组局成功

                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                        elseif code == "pdk_request_disbandGroup" then
                            --同意解散组局

                            dump("同意解散组局", "-----斗地主同意解散组局-----")

                            require("pdk.pdkServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(1)


                        -- 诈金花申请解散
                        elseif code == "zjh_disbandGroup" then
                            --申请解散组局
                            dump("申请解散组局", "-----跑得快-----")

                            dump(bm.Room.UserInfo, "-----跑得快-----")

                            require("zhajinhua.ZhajinHuaServer"):C2G_CMD_DISSOLVE_ROOM()


                        elseif code == "zjh_disbandGroup_success" then
                            --解散组局成功

                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                        elseif code == "zjh_request_disbandGroup" then
                            --同意解散组局

                            dump("同意解散组局", "-----诈金花同意解散组局-----")

                            require("zhajinhua.ZhajinHuaServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(1)

                        elseif code == "ddz_disbandGroup_success" then
                            --解散组局成功

                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                        end



                    end

                end

                --下次吧（取消）
                if sender == btnCancel then

                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end

                    if code then
                        if code == "kwx_liangdao_remaid" then
                            --todo
                            if KWX_CONTROLLER then
                                --todo
                                KWX_CONTROLLER:replyLiangdaoRemaid(false)
                            end
                        elseif code == "cs_disbandGroup" then
                            --申请退出组局

                        elseif code == "cs_request_disbandGroup" then
                            --拒绝解散组局
                            if CSMJ_CONTROLLER then
                                --todo
                                CSMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end
                            --推倒胡麻将
                        elseif code == "tdh_request_disbandGroup" then
                            if TDHMJ_CONTROLLER then
                                TDHMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end
                            --168麻将
                        elseif code == "YKMJ_request_disbandGroup" then
                            if YKMJ_CONTROLLER then
                                YKMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end
                            --海南麻将
                        elseif code == "HNMJ_request_disbandGroup" then
                            if HNMJ_CONTROLLER then
                                HNMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end 
                            --红中麻将
                        elseif code == "ZZMJ_request_disbandGroup" then
                            if ZZMJ_CONTROLLER then
                                ZZMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end 
                            --广东麻将
                        elseif code == "GDMJ_request_disbandGroup" then
                            if GDMJ_CONTROLLER then
                                GDMJ_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end 
                        elseif code == "kwx_request_disbandGroup" then
                            --拒绝解散组局
                            if KWX_CONTROLLER then
                                --todo
                                KWX_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end
                        elseif code == "szkwx_request_disbandGroup" then
                            --拒绝解散组局
                            if SZKWX_CONTROLLER then
                                --todo
                                SZKWX_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end
                        elseif code == "xykwx_request_disbandGroup" then
                            --拒绝解散组局
                            if XYKWX_CONTROLLER then
                                --todo
                                XYKWX_CONTROLLER:C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                            end
                        elseif code == "disbandGroup" then
                            --申请退出组局

                        elseif code == "request_disbandGroup" then
                            --拒绝解散组局
                            require("majiang.scenes.MajiangroomServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(0)

                        elseif code == "disbandGroup_success" then
                            --解散组局成功
                            require("majiang.ddzSettings"):setEndGroup(2)
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                        elseif code == "cs_disbandGroup_success" then
                            --解散组局成功
                            -- require("majiang.ddzSettings"):setEndGroup(2)
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                        elseif code == "disbandGroup_fail" then
                            --解散组局失败


                        --牛牛相关
                        elseif code == "niuniu_disbandGroup" then
                            --申请退出组局

                        elseif code == "niuniu_request_disbandGroup" then
                            --拒绝解散组局
                            dump("拒绝解散组局", "-----牛牛拒绝解散组局-----")
                            require("niuniu.niuniuNamal.NiuniuroomServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(0)

                        elseif code == "niuniu_disbandGroup_success" then
                            --解散组局成功
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])


                        --斗地主相关
                        elseif code == "ddz_disbandGroup" then
                            --申请退出组局

                        elseif code == "ddz_request_disbandGroup" then
                            --拒绝解散组局
                            dump("拒绝解散组局", "-----斗地主拒绝解散组局-----")
                            require("ddz.ddzServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(0)

                        elseif code == "ddz_disbandGroup_success" then
                            --解散组局成功
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                        --跑得快相关
                        elseif code == "pdk_disbandGroup" then
                            --申请退出组局

                        elseif code == "pdk_request_disbandGroup" then
                            --拒绝解散组局
                            dump("拒绝解散组局", "-----斗地主拒绝解散组局-----")
                            require("pdk.pdkServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(0)

                        elseif code == "pdk_disbandGroup_success" then
                            --解散组局成功
                            require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])

                        elseif code == "zjh_request_disbandGroup" then
                            --同意解散组局

                            dump("拒绝解散组局", "-----诈金花拒绝解散组局-----")

                            require("zhajinhua.ZhajinHuaServer"):C2G_CMD_REPLY_DISSOLVE_ROOM(0)
                        end

                    end
                elseif  sender == btn_sure then
                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end
                end
            end
        end

        btnSubmit:addTouchEventListener(touchEvent)
        btnCancel:addTouchEventListener(touchEvent)
        btn_sure:addTouchEventListener(touchEvent)

    end

end

--解散功能专用弹出框
function GameTips:showNotice(title,code,bShowButton,msg,data)

    require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()

    if bShowButton then
        print("show button state:"..tostring(bShowButton))
    end
    bShowButton = bShowButton or 0
    msg = msg or ""
    data = data or ""

    if SCENENOW["scene"] then

        --释放之前的
        local s = SCENENOW["scene"]:getChildByName("layer_tips")
        if s then
            s:removeSelf()
        end

        s = cc.CSLoader:createNode("hall/tips/LayerTips_notify.csb")
        --s:getChildByName("tips_back_1"):setTexture("hall/tips/tips_back.png")
        s:setName("layer_tips")
        SCENENOW["scene"]:addChild(s,99998)

        local layer = s:getChildByName("tips_back_1")
        local txt = layer:getChildByName("txt_msg")
        if txt then
             txt:setString(title)
        end

        local lbTitle = layer:getChildByName("txt_title")
        if lbTitle then
            lbTitle:enableOutline(cc.c4b(58,35,10,255),1)
        end

        local msg_tt = layer:getChildByName("msg_tt")
        msg_tt:setString(msg)

        local btnSubmit = layer:getChildByName("btn_submit")
        btnSubmit:setScale(0.8)

        local btnCancel = layer:getChildByName("btn_cancel")
        btnCancel:setScale(0.8)

        local btn_sure =  layer:getChildByName("btn_sure")
        btn_sure:setScale(0.8)

        if bShowButton == 0 then
            btn_sure:setVisible(true)
            btnCancel:setVisible(false)
            btnSubmit:setVisible(false)
        else
            btn_sure:setVisible(false)
        end

        if bShowButton == 1 then--全部显示

        elseif bShowButton == 2 then--只显示取消按钮

            btnSubmit:setVisible(false)
            btnSubmit:setPosition(cc.p(960,58))

            btnCancel:setVisible(true)
            btnCancel:setPosition(cc.p(398.48, 99.00))

            btn_sure:setVisible(false)

        elseif bShowButton == 3 then--只显示确定按钮

            btnSubmit:setVisible(true)
            btnSubmit:setPosition(cc.p(398.48, 99.00))

            btnCancel:setVisible(false)
            btnCancel:setPosition(cc.p(960,58))

            btn_sure:setVisible(false)

        elseif bShowButton == 4 then
             btnSubmit:setVisible(false)
             btnCancel:setVisible(false)
             btn_sure:setVisible(false)

        end

        local function touchEvent(sender, event)

            --触摸开始
            if event == TOUCH_EVENT_BEGAN then
                sender:setScale(0.7)
            end

            --触摸取消
            if event == TOUCH_EVENT_CANCELED then
                sender:setScale(0.8)
            end

            --触摸结束
            if event == TOUCH_EVENT_ENDED then
                sender:setScale(0.8)

                require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")

                --现在去（确定）
                if sender == btnSubmit then

                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end

                end

                --下次吧（取消）
                if sender == btnCancel then

                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end

                end
                    
                if sender == btn_sure then

                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end

                end

            end
        end

        btnSubmit:addTouchEventListener(touchEvent)
        btnCancel:addTouchEventListener(touchEvent)
        btn_sure:addTouchEventListener(touchEvent)

    end

end

function GameTips:showTipsUpdate(title,url,version,gid,code,see)

    require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()
    
    -- body
    print("show tips")
    see = see or 1
    if SCENENOW["scene"] then
        local s = cc.CSLoader:createNode("hall/tips/LayerTips_new.csb")
        s:setName("layer_tips")
        SCENENOW["scene"]:addChild(s,99999)
        local layer = s:getChildByName("tips_back_1")
        local txt = layer:getChildByName("txt_msg")
        if txt then
            txt:setString(title)
            txt:enableOutline(cc.c4b(58,35,10,255),1)
        end
        local lbTitle = layer:getChildByName("txt_title")
        if lbTitle then
            lbTitle:enableOutline(cc.c4b(58,35,10,255),1)
        end

        local btnSubmit = layer:getChildByName("btn_submit")
        local btnCancel = layer:getChildByName("btn_cancel")
        local btn_sure =  layer:getChildByName("btn_sure")
        btn_sure:setVisible(false)

        local function touchEvent(sender, event)
            if event == TOUCH_EVENT_ENDED then
                require("hall.GameCommon"):playEffectSound("hall/Audio_Button_Click.mp3")
                if sender == btnSubmit then
                    if SCENENOW["scene"]:getChildByName("layer_tips") then
                        SCENENOW["scene"]:removeChildByName("layer_tips")
                    end
                    if see > 0 then
                        require("hall.GameUpdate"):updateGame(url,version,gid,code)
                    else
                        require("hall.GameUpdate"):updteGameUnsee(url,version,gid,code)
                    end
                end
                if sender == btnCancel then
                    -- if isGroup then
                    if require("hall.gameSettings"):getGameMode() == "group" then
                        require("hall.GameCommon"):gExitGroupGame(USER_INFO["enter_mode"])
                    else
                        require("hall.GameCommon"):gExitGame();
                    end
                end
            end
        end

        btnSubmit:addTouchEventListener(touchEvent)
        btnCancel:addTouchEventListener(touchEvent)
    end
end
--处理比赛奖励报名
function GameTips:HandleGameAwardPool()
    -- body
end
--处理兑换宝贝币
function GameTips:ChangeMoney()
    -- body
end

function GameTips:Proxy()
    if SCENENOW['scene'] then
        local proxy_layout=cc.CSLoader:createNode('hall/tips/proxy.csb')
        proxy_layout:setName("proxy")
        SCENENOW['scene']:addChild(proxy_layout,99999)
        local proxy_define = proxy_layout:getChildByName("Button_1")
        local function touchEvent(sender, event)
            if event == TOUCH_EVENT_ENDED then
               if SCENENOW['scene']:getChildByName("proxy") then
                    SCENENOW['scene']:removeChildByName("proxy")     
               end
            end
        end
        proxy_define:addTouchEventListener(touchEvent)
     
    end
end

-- 显示IP提示
function GameTips:showIPAlert( data )
    -- body
    local ip_list = {}
    for k, v in pairs(data) do
        local uid = tonumber(v["uid"])
        if uid ~= tonumber(UID) and uid ~= 0 then
            if ip_list[v["ip"]] == nil then
                ip_list[v["ip"]] = 1
            else
                ip_list[v["ip"]] = ip_list[v["ip"]] + 1
            end
        end
    end

    local same_ip = {}
    for k, v in pairs(ip_list) do
        print("ip_list ",tostring(k), tostring(v))
        if v > 1 then
            same_ip[k] = 1
        end
    end


    local msg = "玩家："
    local show_alert = 0
    if bm.Room ~= nil and bm.Room.UserInfo then
        for k, v in pairs(data) do
            if same_ip[v["ip"]] ~= nil then
                local uid = tonumber(v["uid"])
                if bm.Room.UserInfo[uid] then
                    if bm.Room.UserInfo[uid]["nick"] == nil then
                        local othInfo = json.decode(bm.Room.UserInfo[uid]["user_info"])
                        msg = msg .. "  "..othInfo.nickName
                    else
                        msg = msg .. "  "..bm.Room.UserInfo[uid]["nick"]
                    end
                    show_alert = 1
                end
            end
        end
    end

    if show_alert == 1 then
        require("hall.GameCommon"):showAlert(false)
        require("hall.GameCommon"):showAlert(true, "提示：" .. msg .. "  ip地址相同，谨防作弊", 300)
    end
end


-- 返回大厅
function GameTips:enterHall()
    --移除录音按钮
    require("hall.VoiceRecord.VoiceRecordView"):removeView()

    --设置不需要检查重连
    bm.notCheckReload = 1
    bm.forward_msg_flag = {}

    require("hall.VoiceRecord.VoiceRecordView"):removeView()

    --离开房间
    display_scene("hall.gameScene")
    audio.stopMusic()

    --通知本地退出房间
    require("hall.util.GameUtil"):LogoutRoom()
end

return GameTips