
local Wechat = {}

function Wechat.reqOrderId(id, callback)

	-- loading
	require("hall.NetworkLoadingView.NetworkLoadingView"):showLoading("请求支付中")

	local payType = "wx"
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
				if not netData or not data1 then
					require("hall.GameTips"):showTips("提示", "", 3, "请求订单失败")
					return
				end

				-- 请求成功，调起支付
				local args = {
					orderNum = data1["orderNo"],  -- 订单、
					payValue = tonumber(data1["price"]) / 100, -- 价格 ,元
					appid = data1["appid"], -- appid
					partnerid = data1["partnerid"], -- 商户号
					prepayid = data1["prepayid"], -- 预支付交易会话ID
					package = data1["package"], -- 扩展字段 此值不变
					noncestr = data1["noncestr"], -- 随机字符串
					timestamp = data1["timestamp"], -- 时间戳
					sign = data1["sign"] 	-- 签名
				}	
				Wechat.pay(args, callback)
				
			end,
			type_="GET"--"POST"
		})
end

function Wechat.pay(args, callback)
	-- 回调
	-- local function callback(code)
	-- 	if code == "true" then
	-- 		-- 支付成功
	-- 		require("hall.GameTips"):showTips("提示", "", 3, "支付成功")
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
	elseif device.platform == "ios" then
		params = args
		-- 回调
		params.listener = callback
	end
	SDKAdape.onWechatPay(params, "V")
end

return Wechat

