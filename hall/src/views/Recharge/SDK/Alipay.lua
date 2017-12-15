
local Alipay = {}

function Alipay.reqOrderId(id, callback)

	-- loading
	require("hall.NetworkLoadingView.NetworkLoadingView"):showLoading("请求支付中")


	local payType = "zfb"
    local httpurl = HttpAddr2.."common/pay/doAddOrderForPlayer"
    cct.createHttRq({
			url = httpurl,
			date={
                userId = USER_INFO["uid"],
				fId = id,
				payType = payType
            },

			callBack = function(data)

				require("hall.NetworkLoadingView.NetworkLoadingView"):removeView()

				local netData = json.decode(data["netData"])
				local data1 = netData["data1"]
				local data2 = netData["data2"]
				if not netData or not data1 or not data2 then
					require("hall.GameTips"):showTips("提示", "", 3, "请求订单失败")
					return
				end
                local dedata2 = json.decode(data2)
                if not dedata2 then
                    require("hall.GameTips"):showTips("提示", "", 3, "请求订单失败")
                    return
                end

				-- 请求成功，调起支付
				local args = {
					orderNum = dedata2["orderId"],  -- 订单、
					payValue = tonumber(dedata2["price"]) / 100, -- 价格 ,元
					sign = data1 	-- 签名
				}	
				Alipay.pay(args, callback)
				
			end,
			type_="GET"--"POST"
		})
end

function Alipay.pay(args, callback)
	-- 回调
	-- local function callback(code)
	-- 	if code == "true" then
	-- 		-- 支付成功
	-- 		--require("hall.GameTips"):showTips("提示", "", 3, "支付成功")
 --            -- 请求刷新房卡
	-- 	elseif code == "false" then
	-- 		-- 支付失败
	-- 		require("hall.GameTips"):showTips("提示", "", 3, "支付失败")
	-- 	end
	-- end



	local params = {}

	if device.platform == "android" then

		params = {
			json.encode(args),
			callback -- 回调
		}
		SDKAdape.onAlipayPay(params, "V")
	elseif device.platform == "ios" then
		params = args
		-- 回调
		--params.listener = callback
	end
end

return Alipay

