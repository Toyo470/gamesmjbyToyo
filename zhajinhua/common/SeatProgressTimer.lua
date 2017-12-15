--
-- Author: Johnny Lee
-- Date: 2014-07-10 17:09:59
--


local SeatProgressTimer = class("SeatProgressTimer", function()
    return cc.RenderTexture:create(display.width, display.height)
end)

function SeatProgressTimer:ctor(countdown,file,width,height)

    self:init(width,height)
    self.file  = file
    self.break_f = false
    -- 打开node event
    self:setNodeEventEnabled(true)

    -- 根据countdown计算必须数据
    self:setCountdown(countdown - 1)

    -- 添加帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
end

function SeatProgressTimer:init(width,height)
        -- 计时器数据
        self.TIMER_BORDER_WIDTH     = width
        self.TIMER_BORDER_HEIGHT    = height
        self.TIMER_BORDER_THICKNESS = 4
        self.TIMER_CORNER_RADIUS    = 10
        self.POSITION_OFFSET        = 2

        -- 移动区间标志
        self.STOP                = 0
        self.TOP_RIGHT           = 1
        self.TOP_RIGHT_CORNER    = 2
        self.RIGHT               = 3
        self.BOTTOM_RIGHT_CORNER = 4
        self.BOTTOM              = 5
        self.BOTTOM_LEFT_CORNER  = 6
        self.LEFT                = 7
        self.TOP_LEFT_CORNER     = 8
        self.TOP_LEFT            = 9

        -- 转角坐标
        self.temp1 = self.TIMER_BORDER_WIDTH * 0.5 - self.TIMER_CORNER_RADIUS - self.POSITION_OFFSET
        self.temp2 = self.TIMER_BORDER_HEIGHT * 0.5 - self.TIMER_CORNER_RADIUS - self.POSITION_OFFSET
        self.TOP_RIGHT_CORNER_POINT    = cc.p(display.cx + self.temp1, display.cy + self.temp2)
        self.BOTTOM_RIGHT_CORNER_POINT = cc.p(display.cx + self.temp1, display.cy - self.temp2)
        self.BOTTOM_LEFT_CORNER_POINT  = cc.p(display.cx - self.temp1, display.cy - self.temp2)
        self.TOP_LEFT_CORNER_POINT     = cc.p(display.cx - self.temp1, display.cy + self.temp2)

        -- 颜色变换标记
        self.GREEN_TO_YELLOW = 1
        self.YELLOW_TO_RED   = 2

        -- 计算必须数据
        self.timerCountdown        = 0 -- 倒计时秒数
        self.timerBorderPerimeter  = (self.TIMER_BORDER_WIDTH - self.TIMER_CORNER_RADIUS * 2 - self.TIMER_BORDER_THICKNESS + self.TIMER_BORDER_HEIGHT - self.TIMER_CORNER_RADIUS * 2 - self.TIMER_BORDER_THICKNESS) * 2 + 0.5 * math.pi * self.TIMER_CORNER_RADIUS * 4 -- 计时器周长
        self.lineVelocity          = 0 -- 线速度
        self.angularVelocity       = 0 -- 角速度
        self.colorVelocity         = 0 -- 颜色变换速度
        self.totalFrames           = 0
end

function SeatProgressTimer:setbreak()
    -- body
    self.break_f = true
end

function SeatProgressTimer:setCountdown(second)
    if second == self.timerCountdown then return end
    -- 设置countdown，计算线速度与角速度
    self.timerCountdown = second
    self.lineVelocity = self.timerBorderPerimeter * cc.Director:getInstance():getAnimationInterval() / self.timerCountdown -- 周长除以帧数，得到每帧的位移量
    self.angularVelocity = 90 / (0.5 * math.pi * self.TIMER_CORNER_RADIUS / self.lineVelocity); -- 得到每帧的角度偏移量（经过一个90度的角度）
    
    -- 计算颜色变化速率
    self.colorVelocity = 255 * cc.Director:getInstance():getAnimationInterval() / (self.timerCountdown * 0.25)
    self.totalFrames = math.round(second / cc.Director:getInstance():getAnimationInterval())
end

function SeatProgressTimer:onEnter()
    -- 添加至舞台开始渲染
    self.frameCount_ = 0
    self.countStartTime_ = bm.getTime()

    -- 设置当前动画阶段，颜色变化阶段
    self.animationPhrase_ = self.TOP_RIGHT
    self.colorPhase_      = self.GREEN_TO_YELLOW

    -- 设置初始颜色
    self.redColor_        = 0
    self.greenColor_      = 255

    -- 创建橡皮擦并retain
    self.erase_ = display.newSprite("#room_seat_timer_brush.png")
    self.erase_:retain()
    self.erase_:setBlendFunc(gl.ZERO,gl.ONE_MINUS_SRC_ALPHA)
    self.eraseX_ = display.cx
    self.eraseY_ = display.cy + self.TIMER_BORDER_HEIGHT * 0.5 - self.POSITION_OFFSET
    self.eraseR_ = 0

    -- 渲染到画布上
    self:clear(0, 0, 0, 0)
    self:begin()
    -- display.newSprite("#room_seat_timer_canvas.png"):pos(display.cx, display.cy):visit()
    display.newSprite(self.file):pos(display.cx-1, display.cy-1):visit()
    self:endToLua()
    self:getSprite():setColor(cc.c3b(self.redColor_, self.greenColor_, 0))
    self:getSprite():getTexture():setAntiAliasTexParameters()

    self:scheduleUpdate()
end

function SeatProgressTimer:onEnterFrame(evt, isFastForward)

    if self.break_f  == true then
        self:removeFromParent()
        self.break_f = false
        return false
    end
    self.frameCount_ = self.frameCount_ + 1

    local tanValue       = 0
    local offsetX        = 0
    local offsetY        = 0
    local eraseX         = self.eraseX_
    local eraseY         = self.eraseY_
    local eraseR         = self.eraseR_
    local redColor       = self.redColor_
    local greenColor     = self.greenColor_
    local colorPhase     = self.colorPhase_
    local animationPhase = self.animationPhrase_

    -- 颜色变换
    if animationPhase >= self.BOTTOM_RIGHT_CORNER then
        if colorPhase == self.GREEN_TO_YELLOW then -- self.GREEN_TO_YELLOW phase
            redColor = redColor + self.colorVelocity
            if redColor >= 255 then
                redColor = 255
                colorPhase = self.YELLOW_TO_RED
            end
        elseif colorPhase == self.YELLOW_TO_RED then -- self.YELLOW_TO_RED phase
            greenColor = greenColor - self.colorVelocity
            if greenColor <= 0 then
                greenColor = 0
                colorPhase = self.STOP
            end
        end
    end

    -- 位置变换
    if animationPhase == self.TOP_RIGHT then -- self.TOP_RIGHT phase
        eraseX = eraseX + self.lineVelocity
        if eraseX >= self.TOP_RIGHT_CORNER_POINT.x then
            eraseX = self.TOP_RIGHT_CORNER_POINT.x
            animationPhase = self.TOP_RIGHT_CORNER
        end
    elseif animationPhase == self.TOP_RIGHT_CORNER then -- self.TOP_RIGHT_CORNER phase
        eraseR = eraseR + self.angularVelocity
        if eraseR < 90 then
            tanValue = math.tan(math.rad(eraseR))
            offsetY = self.TIMER_CORNER_RADIUS / (math.sqrt(1 + tanValue * tanValue))
            offsetX = offsetY * tanValue
            eraseX = self.TOP_RIGHT_CORNER_POINT.x + offsetX
            eraseY = self.TOP_RIGHT_CORNER_POINT.y + offsetY
        else
            eraseX = self.TOP_RIGHT_CORNER_POINT.x + self.TIMER_CORNER_RADIUS
            eraseY = self.TOP_RIGHT_CORNER_POINT.y
            eraseR = 90
            animationPhase = self.RIGHT
        end
    elseif animationPhase == self.RIGHT then -- self.RIGHT phase
        eraseY = eraseY - self.lineVelocity
        if eraseY <= self.BOTTOM_RIGHT_CORNER_POINT.y then
            eraseY = self.BOTTOM_RIGHT_CORNER_POINT.y
            animationPhase = self.BOTTOM_RIGHT_CORNER
        end
    elseif animationPhase == self.BOTTOM_RIGHT_CORNER then -- self.BOTTOM_RIGHT_CORNER phase
        eraseR = eraseR + self.angularVelocity
        if eraseR < 180 then
            tanValue = math.tan(math.rad(eraseR - 90))
            offsetX = self.TIMER_CORNER_RADIUS / (math.sqrt(1 + tanValue * tanValue))
            offsetY = offsetX * tanValue
            eraseX = self.BOTTOM_RIGHT_CORNER_POINT.x + offsetX
            eraseY = self.BOTTOM_RIGHT_CORNER_POINT.y - offsetY
        else
            eraseX = self.BOTTOM_RIGHT_CORNER_POINT.x
            eraseY = self.BOTTOM_RIGHT_CORNER_POINT.y - self.TIMER_CORNER_RADIUS
            eraseR = 180
            animationPhase = self.BOTTOM
        end
    elseif animationPhase == self.BOTTOM then -- self.BOTTOM phase
        eraseX = eraseX - self.lineVelocity
        if eraseX <= self.BOTTOM_LEFT_CORNER_POINT.x then
            eraseX = self.BOTTOM_LEFT_CORNER_POINT.x
            animationPhase = self.BOTTOM_LEFT_CORNER
        end
    elseif animationPhase == self.BOTTOM_LEFT_CORNER then -- self.BOTTOM_LEFT_CORNER phase
        eraseR = eraseR + self.angularVelocity
        if eraseR < 270 then
            tanValue = math.tan(math.rad(eraseR - 180))
            offsetY = self.TIMER_CORNER_RADIUS / (math.sqrt(1 + tanValue * tanValue))
            offsetX = offsetY * tanValue
            eraseX = self.BOTTOM_LEFT_CORNER_POINT.x - offsetX
            eraseY = self.BOTTOM_LEFT_CORNER_POINT.y - offsetY
        else
            eraseX = self.BOTTOM_LEFT_CORNER_POINT.x - self.TIMER_CORNER_RADIUS
            eraseY = self.BOTTOM_LEFT_CORNER_POINT.y
            eraseR = 270
            animationPhase = self.LEFT
        end
    elseif animationPhase == self.LEFT then -- self.LEFT phase
        eraseY = eraseY + self.lineVelocity
        if eraseY >= self.TOP_LEFT_CORNER_POINT.y then
            eraseY = self.TOP_LEFT_CORNER_POINT.y
            animationPhase = self.TOP_LEFT_CORNER
        end
    elseif animationPhase == self.TOP_LEFT_CORNER then -- self.TOP_LEFT_CORNER phase
        eraseR = eraseR + self.angularVelocity
        if eraseR < 360 then
            tanValue = math.tan(math.rad(eraseR - 270))
            offsetX = self.TIMER_CORNER_RADIUS / (math.sqrt(1 + tanValue * tanValue))
            offsetY = offsetX * tanValue
            eraseX = self.TOP_LEFT_CORNER_POINT.x - offsetX
            eraseY = self.TOP_LEFT_CORNER_POINT.y + offsetY
        else
            eraseX = self.TOP_LEFT_CORNER_POINT.x
            eraseY = self.TOP_LEFT_CORNER_POINT.y + self.TIMER_CORNER_RADIUS
            eraseR = 360
            animationPhase = self.TOP_LEFT
        end
    elseif animationPhase == self.TOP_LEFT then -- self.TOP_LEFT phase
        eraseX = eraseX + self.lineVelocity
        if eraseX >= display.cx then
            eraseX = display.cx
            animationPhase = self.STOP

            -- 结束动画时从舞台移除
            self:removeFromParent()
            return
        end
    end

    -- 设置阶段
    self.animationPhrase_ = animationPhase
    self.colorPhase_      = colorPhase

    -- 设置橡皮擦的位置，旋转角度
    self.eraseX_ = eraseX
    self.eraseY_ = eraseY
    self.eraseR_ = eraseR
    self.erase_:pos(self.eraseX_, self.eraseY_):setRotation(self.eraseR_)

    -- 开始擦除
    self:begin()
    self.erase_:visit()
    self:endToLua()

    -- 设置颜色
    self.redColor_ = redColor
    self.greenColor_ = greenColor
    self:getSprite():setColor(cc.c3b(self.redColor_, self.greenColor_, 0))

    if not isFastForward then
        --掉帧处理
        local curFrame = math.round((bm.getTime() - self.countStartTime_) * self.totalFrames / self.timerCountdown)
        if curFrame > self.frameCount_ then
            for i = 1, curFrame - self.frameCount_ do
                self:onEnterFrame(nil, true)
                if not self:getParent()  or self.break_f  == true then
                    break
                end
            end
        end
    end
end

-- 重置计时器（移除舞台时自动调用）
function SeatProgressTimer:onExit()
    self:unscheduleUpdate()
    self.erase_:release()
end

-- 清理
function SeatProgressTimer:dispose()
    -- 释放retain的对象
    self.erase_:release()

    -- 移除node事件
    self:unscheduleUpdate()
    self:removeAllNodeEventListeners()

    self:clear(0, 0, 0, 0)
end


function SeatProgressTimer:removeMine()
    -- body
    self:removeFromParent()
end

return SeatProgressTimer