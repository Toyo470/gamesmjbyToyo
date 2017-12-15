local LeaderLayer = class("LeaderLayer")

function LeaderLayer:showLeaderLayer(desPosition)
    if not desPosition then
        --todo
        return
    end

    if cc.UserDefault:getInstance():getIntegerForKey("isLeaderPlayed") and cc.UserDefault:getInstance():getIntegerForKey("isLeaderPlayed") == 1 then
        --todo
        return
    end

    cc.UserDefault:getInstance():setIntegerForKey("isLeaderPlayed", 1)

    local desc_offset_x = 833.59 - 887.13
    local desc_offset_y = 121.57 - 190.58

	local layout = cc.CSLoader:createNode("hall/leader/LeaderLayer.csb"):addTo(SCENENOW["scene"])
	local leader_plane = layout:getChildByName("leader_plane")

	local guangquan_img = leader_plane:getChildByName("guangquan_img")
    local guangdian_img = leader_plane:getChildByName("guangdian_img")
    local hand_img = leader_plane:getChildByName("hand_img")
    local desc_plane = leader_plane:getChildByName("desc_plane")

    local hand_ori_position = hand_img:getPosition()

    guangquan_img:setVisible(false)
    guangdian_img:setVisible(false)
    desc_plane:setVisible(false)

    guangquan_img:setPosition(desPosition)
    guangdian_img:setPosition(desPosition)
    desc_plane:setPosition(cc.p(desPosition.x + desc_offset_x, desPosition.y + desc_offset_y))

    leader_plane.noScale=true
    leader_plane:onClick(function()
        layout:removeFromParent()
    end)

    local hand_des_x = desPosition.x - guangdian_img:getSize().width / 2 - hand_img:getSize().width / 2 + 20
    local hand_des_y = desPosition.y - guangdian_img:getSize().height / 2 - hand_img:getSize().height / 2 + 20

    leaderFunc = function()
        local moveAc = cc.MoveTo:create(1, cc.p(hand_des_x, hand_des_y))
        local moveDone = cc.CallFunc:create(function()
                guangdian_img:setVisible(true)

                guangdian_img:setOpacity(0.2 * 255)
                guangquan_img:setScale(0.2)
            end)
        local waitAc = cc.DelayTime:create(0.1)
        local clickAc = cc.CallFunc:create(function()
                
                guangquan_img:setVisible(true)

                hand_img:loadTexture("hall/images/leader/finger02.png")
                
                desc_plane:setVisible(true)
                guangdian_img:setOpacity(1 * 255)

                local scaleAc = cc.ScaleTo:create(0.5, 1, 1)
                local scaleDoneAc = cc.CallFunc:create(function()
                        -- guangquan_img:setScale(0.2)
                        -- guangdian_img:setOpacity(0.2 * 255)

                        hand_img:loadTexture("hall/images/leader/finger01.png")
                        -- desc_plane:setVisible(false)
                    end)
                local scaleWaitAc = cc.DelayTime:create(0.1)
                local allDoneAc = cc.CallFunc:create(function()
                        hand_img:setPosition(hand_ori_position)
                        guangquan_img:setVisible(false)
                        guangdian_img:setVisible(false)

                        leaderFunc()
                    end)
                local guangquanSeqAc = cc.Sequence:create(scaleAc, scaleDoneAc, scaleWaitAc)

                guangquan_img:runAction(guangquanSeqAc)
            end)

        local seqAction = cc.Sequence:create(moveAc, moveDone, waitAc, clickAc)   
        hand_img:runAction(seqAction)
    end

    leaderFunc()
end

return LeaderLayer