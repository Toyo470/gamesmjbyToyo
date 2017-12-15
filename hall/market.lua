require("cocos.framework.extends.UIWidget")
local Recharge = require("hall.Recharge")



local Market_Pay = class("Market_Pay",function()
    return display.newNode()
end)

function Market_Pay:ctor()
    local  csb_path_name = "hall/market/market_pay.csb"
    self:init_csb(csb_path_name)
    self.goods_id = ""
end


function Market_Pay:init_csb( csb_path_name )
    local view = cc.CSLoader:createNode(csb_path_name):addTo(self)
    view:setName("view")

    local yinliang = view:getChildByName("yinliang")
    local zifubao = view:getChildByName("zifubao")
    local weixin = view:getChildByName("weixin")
    local close_btn = view:getChildByName("btn_close")

    yinliang:onTouch(handler(self,self.close_call_back))
    zifubao:onTouch(handler(self,self.close_call_back))
    weixin:onTouch(handler(self,self.close_call_back))
    close_btn:onTouch(handler(self,self.close_call_back))

    -- local pay_layout02_1 = view:getChildByName("pay_layout02_1")
    -- pay_layout02_1:setTexture("hall/market/pay_layout02.png")

    -- local yinlian_3 = yinliang:getChildByName("yinlian_3")
    -- yinlian_3:setTexture("hall/market/yinlian.png")

    -- local yinlian_3 = zifubao:getChildByName("yinlian_3")
    -- yinlian_3:setTexture("hall/market/zhifubao.png") 

    -- local yinlian_3 = weixin:getChildByName("yinlian_3")
    -- yinlian_3:setTexture("hall/market/weixin.png")

    -- local btn_close_6 = close_btn:getChildByName("btn_close_6")
    -- btn_close_6:setTexture("hall/market/btn_close.png")

end

function Market_Pay:init_data(data_tbl)
    local view = self:getChildByName("view")
    if view == nil then return end

    local goods_name = view:getChildByName("goods_name")
    local goods_money = view:getChildByName("goods_money")
   -- dump(data_tbl,"data_tbl")
    goods_name:setString(tostring(data_tbl.amount))
    goods_money:setString(tostring(data_tbl.price))

    self.goods_id = data_tbl.goodsId
    self.data_tbl = data_tbl
end

function Market_Pay:close_call_back( event )
    -- body
    if event.name == "began" then
        event.target:setScale(0.7)
    elseif  event.name == "moved" then
       event.target:setScale(1.0)
    elseif event.name == "ended" then
       event.target:setScale(1.0)

       local target_name = event.target:getName()
       if "btn_close" == target_name then
            self:setVisible(false)
            return
       end
       self:setVisible(false)

       local pay_type = ""
       if "yinliang" == target_name then
           pay_type = "U"
       elseif "zifubao" == target_name then
           pay_type = "P"
       elseif "weixin" == target_name then
           pay_type = "W"
       end

       local data = self.data_tbl
       dump(data,"++++++++++++++++++++++++++++++++")
       local args = {data.price, pay_type, data.amount}
       
       local argss = {}
            argss["payAmount"] = data.price
            argss["payType"] = pay_type
            argss["coinAmount"] = data.amount

       dump(args)
       dump(argss)

       Recharge:call_recharge(data.price,pay_type,data.amount)
    end
end


local Market = class("Market", function()
    return display.newNode()
end)


function Market:ctor(call_back)
    self.market_data = {}
    --self:init_market_data()
    self.view_base = nil

   local csb_path_name = "hall/market/market.csb"
   self:init_csb_node(csb_path_name)

   self.call_back=call_back

   if USER_INFO["market_data"] then 
        self:market_data_callBack(USER_INFO["market_data"])
   else
        self:call_http()
   end

    if SCENENOW["scene"].set_hall_base then
        SCENENOW["scene"]:set_hall_base()
    end

end

function  Market:call_http()
    -- body
    -- HttpAddr = "http://120.76.133.49/hbiInterface"
    cct.createHttRq({
            url=HttpAddr .. "/goods/queryGoodsList",--http://120.76.133.49:80/hbiInterface/goods/queryGoodsList
            date={
                type=0,
                device = 1,
                interfaceType = "j"
            },
            type_="GET",
            callBack = function(data)
            self:market_data_callBack(data)
         end
        })
end

function Market:get_icon_path( gold_num )
    -- body
    local icon_path = ""
    if gold_num < 1000 then
        icon_path = "hall/market/shop_gold01.png"
    elseif gold_num < 2000 then
        icon_path = "hall/market/shop_gold02.png"
    elseif gold_num < 5000 then
        icon_path = "hall/market/shop_gold03.png"
    elseif gold_num < 7000 then
        icon_path = "hall/market/shop_gold04.png"
    elseif gold_num < 9000 then
        icon_path = "hall/market/shop_gold05.png"
    else
        icon_path = "hall/market/shop_gold06.png"
    end
    return icon_path
end


function Market:market_data_callBack( data )
    -- body
    if USER_INFO["market_data"] == nil then
        USER_INFO["market_data"] = data
    end

    if data == nil then
        return
    end
   -- print("====================data=====================")
   -- print(data)
    --dump(data)

    local netData = data["netData"]

    print(netData,"-------------")
    -- local first_num =  string.find(netData, '{')
    -- local last_pos  =  string.find(netData, '}')
    netData  = json.decode(netData)
    -- dump(gameList)
    local goods_list = netData["data"] or {}
    dump(goods_list,"gameList")

   -- local goods_list = {}

    -- table.insert(goods_list,{goodsId = 1,name = "13,000兜币",price = 13,amount=106000 })
    -- table.insert(goods_list,{goodsId = 1,name = "13,000兜币",price = 14,amount=106000})
    -- table.insert(goods_list,{goodsId = 1,name = "13,000兜币",price = 15,amount=106000})
    -- table.insert(goods_list,{goodsId = 1,name = "13,000兜币",price = 16,amount=106000})
    -- table.insert(goods_list,{goodsId = 1,name = "13,000兜币",price = 17,amount=106000})
    -- table.insert(goods_list,{goodsId = 1,name = "13,000兜币",price = 18,amount=106000})
    -- table.insert(goods_list,{goodsId = 1,name = "13,000兜币",price = 11,amount=106000})

    
    table.sort(goods_list,function(v1,v2) return v1.price < v2.price end)

    local tb={}
    local num=0
    local te={}
    for _,room in pairs(goods_list) do 
        num=num+1;
        if num>6 then --last
            table.insert(tb,te) 
            print("insert------------------------1")
            te={}
            num=0
        end--游戏的level
        table.insert(te,room)

    end

    if table.getn(te) > 0 then --num == 0表示刚刚好上面6个6个的插入好
        table.insert(tb,te)
        print("insert------------------------1")
        te={}
        num=0
    end

    self:addto_scrollview(tb)

end

function Market:addto_scrollview(list_table)
    dump(list_table)
    if self.view_base == nil then
        return
    end

    local pv=self.view_base:getChildByName("page_view")
    if pv == nil then
        print("-----------base_page is null-----------")
        return
    end
print("-----------addto_scrollview---------")
    local len = 0
    for k,v in pairs(list_table) do--页
        local onePage=ccui.Layout:create();
        onePage:setContentSize(cc.p(775,400))
       
        len = 0
        for k1,v1 in pairs(v) do--每一页
            local view_item=self.view_base:getChildByName("view_item"):clone();
            onePage:addChild(view_item)

            len=len+1; 
           -- print("--------------------1--------len-------------",len)

            local _x,_y;
            if len >3 then
                _y=99.48
                _x= 124.00 + (385.00 - 124.00) * (len - 3-1)
            else
                _y = 299.48
                _x= 124.00 + (385.00 - 124.00) * (len-1)
            end
            view_item:setPosition(_x,_y)

            --币数
            local Text_3 = view_item:getChildByName("gold_num")
            Text_3:setString(v1.amount)
            --钱
            local Text_4 = view_item:getChildByName("good_money")
            Text_4:setString("￥"..tostring(v1.price).."元")

            local icon_path = self:get_icon_path(v1.amount or 0)
            --print("icon_path--------------------icon_path",icon_path)
            local Image_gold = view_item:getChildByName("Image_gold")
            Image_gold:loadTexture(icon_path)

            view_item.data = v1
            view_item:onTouch(handler(self,self.touch_call_back))
                

            local Image_1 = view_item:getChildByName("Image_1")
            local Image_5 = view_item:getChildByName("Image_5")
            Image_1:setVisible(false)
            Image_5:setVisible(false)

            --如果没有首冲过
            if USER_INFO["isFirstCharged"] and USER_INFO["isFirstCharged"] == 0 then
                local Image_1 = view_item:getChildByName("Image_1")
                local Image_5 = view_item:getChildByName("Image_5")
                Image_1:setVisible(true)
                Image_5:setVisible(true)
            end

        end
        pv:addPage(onePage)
    end
end

function Market:init_csb_node( csb_path_name )
    -- body
   -- print("----------------csb_path_name--------------",csb_path_name)
    -- cc.FileUtils:getInstance():addSearchPath("hall/market")
    local view = cc.CSLoader:createNode(csb_path_name):addTo(self)
    self.view_base = view

    local close_btn = view:getChildByName("close_btn")
    close_btn:onTouch(handler(self,self.close_call_back))

    local Panel_9 = view:getChildByName("Panel_9")
    Panel_9:onTouch(handler(self,self.close_call_back))

    -- local Image_4 = view:getChildByName("Image_4")
    -- local icon_path = "hall/market/layout03.png"
    -- Image_4:loadTexture(icon_path)

    -- local close_btn = self.view_base:getChildByName("close_btn")
    -- local close_btn = close_btn:getChildByName("close_btn")
    -- icon_path = "hall/market/btn_close.png"
    -- close_btn:setTexture(icon_path)

end

function Market:touch_call_back( event )
    -- body
    if event.name == "began" then
        event.target:setScale(0.9)
    elseif  event.name == "moved" then
        event.target:setScale(1.0)
    elseif event.name == "ended" then
        event.target:setScale(1.0)

        local data = event.target.data

        local market_item_pay = self:getChildByName("market_item_pay")
        if market_item_pay ~= nil then
            market_item_pay:setVisible(true)
        else
            market_item_pay = Market_Pay.new()
            market_item_pay:addTo(self)
            market_item_pay:setName("market_item_pay")
        end
        market_item_pay:init_data(data)
    end

end


function Market:close_call_back(event)
    -- body 
    --    if event.name == "began" then
    --     event.target:setScale(0.7)
    -- elseif  event.name == "moved" then
    --    event.target:setScale(1.0)
    -- else
    if event.name == "ended" then
      -- event.target:setScale(1.0)
       local parent = self:getParent()
       if parent then
            if parent.from_market_back then
                parent:from_market_back()
            end
       end

       if self.call_back then
            self.call_back()
       end


       self:removeSelf()
    end
end

return Market


-- local market = Market.new()
-- SCENENOW["scene"]:addChild(market)