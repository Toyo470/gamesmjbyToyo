mrequire("detail.detail_template")
DetailLayout = class("DetailLayout", detail.detail_template.detail_Template)

function DetailLayout:_do_after_init()
	-- zimo 自摸    paohu 炮胡   huazhu 花猪   cdj 查大叫
   --胡基本类型  【平胡：xiaohu、对对胡：ddh、七对：qxd】 

	self.hu_stye = {["zimo"]="自摸", 
					["huazhu"]="花猪",
					["cdj"]="查大叫",	
	}

	-- 胡基本类型  【平胡：xiaohu、对对胡：ddh、七对：qxd】
 	--升级类型【清一色：['xiaohu','qys']、清对:['ddh','qys']、清七对['qxd','qys']、
 										 --龙七对['qxd','gen']、清龙七对:['qxd','qys','gen']】

	--自摸:zimo 天胡：th  地胡:dh   杠:gang    本金:bj 杠上开花:gskh    金钩(钓/炮)：jg 根：gen 
	--        接本金:jbj    无听用:wty

	-- 抢杠胡：qgh   杠上炮：gsp
	

	--根是需要拼， 有自摸的金钩叫金钩钓，没自摸的叫金钩炮。

end

function DetailLayout:reset_data(game_hu_account_data_one_dict,piao_dict)
	-- body
	dump(game_hu_account_data_one_dict,"game_hu_reset_data")

	local result_str = ""

	--shouru收入
	local get_list = game_hu_account_data_one_dict["get_list"] or {}

	local str = "收入: \n\n  "


	for _index,data_dict in pairs(get_list) do	
		    local conis = data_dict["conis"] or 0
			local point = data_dict["point"] or 0
			local target_id_list = data_dict["target_id_list"] or {}
			local hu_list = data_dict["hu_list"] or {}

			local gen_dit = {}
			local gang_dit = {}
			
			local qxd_flag = false
			local qys_flag = false
			local ddh_flag = false
			local xh_flag = false
			local zimo_flag = false
			local th_flag = false
			local dh_flag = false
			local bj_flag = false
			local gskh_flag = false
			local jg_flag = false
			local jbj_flag = false
			local wty_flag = false

			local qgh_flag = false
			local gsp_flag = false
			local huazhu_flag = false

			for _,hutype in pairs(hu_list) do
				if hutype == "qys" then --清一色
					qys_flag = true
				elseif hutype == "qxd" then --七对
					 qxd_flag = true 

				elseif hutype == "ddh" then --对对胡
					ddh_flag = true

				elseif hutype == "gen" then --根
					table.insert(gen_dit,"gen")

				elseif hutype == "gang" then --杠
					table.insert(gang_dit,"gang")

				elseif hutype == "zimo" then --自摸
		 			zimo_flag = true

				elseif hutype == "xiaohu" then --平胡
					xh_flag = true
				elseif hutype == "th" then --天胡
					th_flag = true
				elseif hutype == "dh" then --地胡
					dh_flag = true

				elseif hutype == "bj" then
					bj_flag = true
				elseif hutype == "gskh" then
					gskh_flag = true
				elseif hutype == "jg" then
					jg_flag = true

				elseif hutype == "jbj" then
					jbj_flag = true
				elseif hutype == "wty" then
					wty_flag = true

				elseif hutype == "qgh" then
					qgh_flag = true
				elseif hutype == "gsp" then
					gsp_flag = true
				elseif hutype == "huazhu" then -- 花猪
					huazhu_flag = true
				end
			end
			
			
			--自摸:zimo 天胡：th  地胡:dh 
			if zimo_flag == true then str = str .. "自摸 "
			end

			if th_flag == true then  str = str .. "天胡 "
			end

			if th_flag == true then  str = str .. "地胡  "
			end



			str = str .. "  "
			local qidui_str = ""
			if qxd_flag == true then--七对
				qidui_str = "七对"

				if table.nums(gen_dit) > 0 then
				   qidui_str = "龙" .. qidui_str 
				   table.remove(gen_dit,1)
				end
			
				if  qys_flag == true then
					qidui_str = "清" .. qidui_str
				end

			end
			str = str .. qidui_str
			str = str .. "  "

			local hu_str = ""
			if xh_flag == true then--小胡
				hu_str = "平胡"

			
				if  qys_flag == true then
					hu_str = "清一色" 
				end
			end
			str = str .. hu_str
			str = str .. "  "

			local duidui_str = ""
			if ddh_flag == true then--对对胡
				duidui_str = "对对胡"

				if  qys_flag == true then
					duidui_str = "清对" 
				end
			end
			str = str .. duidui_str

			str = str .. "  "


			--本金:bj 杠上开花:gskh    金钩(钓/炮)：jg
			if bj_flag == true then str = str .. "本金 "
			end

			if gskh_flag == true then  str = str .. "杠上开花 "
			end

			if jg_flag == true then  
				if zimo_flag == true then str = str .. "金钩钓  " 
				else str = str .. "金钩炮  "  end
			end

			-- 接本金:jbj    无听用:wty
			if jbj_flag == true then str = str .. "接本金  " 
			end

			if wty_flag == true then str = str .. "无听用  "
			end

			-- 抢杠胡：qgh   杠上炮：gsp
			if qgh_flag == true then str = str .. "抢杠胡  "
			end 

			if gsp_flag == true then str = str .. " 杠上炮  "
			end

			if huazhu_flag == true then str = str .. "  花猪 "
			end


			if table.nums(gen_dit) > 0 then
				str = str .. "根 X" .. tostring(table.nums(gen_dit)) 
			end

			if table.nums(gang_dit) > 0 then
				str = str .. "杠 X" .. tostring(table.nums(gang_dit)) 
			end
			str = str .. "  "

			if point > 0 then
				str = str .. tostring(point) .. "番"
			end

			str = str .. "  "

			if conis > 0 then
				str = str .. "+" .. tostring(conis)
			end

			if table.nums(target_id_list) > 0 then
				str = str .. "\n"
				str = str .. "关" .. tostring(table.nums(target_id_list)) .. "家  "
				for _,account_id in pairs(target_id_list) do
					local user_data = zzroom.manager:get_user_data(account_id)
					local account_name = user_data["account_name"] or ""
					-- str = str .. account_name .. "   "

					if piao_dict[tostring(account_id)] == 1 then
						str = str .. account_name .. "(飘X2)" .. "   "
					else
						str = str .. account_name .. "   "
					end
				end
				str = str .. "\n"
			end
	end




	str = str .. "\n"
	
	--zhichu支出
	local result_str = "支出".."\n"
	local pay_dict = game_hu_account_data_one_dict["pay_dict"] or {}
	for account_id,detail_tbl in pairs(pay_dict) do
		account_id = tonumber(account_id)
		local user_data = zzroom.manager:get_user_data(account_id)
		local account_name = user_data["account_name"] or ""

		local hu_stye = detail_tbl["hu_stye"]
		local coins = detail_tbl["coins"]

		result_str = result_str .. self.hu_stye[hu_stye] .. " 给 ".. account_name .."  ".. tostring(coins).. "\n"
	end

	str = str .. result_str
	self.detail_tips_dissove_tips_content:setString(str)
end

function DetailLayout:click_detail_close_btn_event()
	self:hide_layout()
end
