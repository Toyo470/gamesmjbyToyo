mrequire("result.jing_result_template")
mrequire("names")

JingResultLayout = class("JingResultLayout", result.jing_result_template.jing_result_Template)

function JingResultLayout:_do_after_init()
    self.__jing_key_list = {
    							names.GAME_UP_JING_CARD_LIST,\
    							names.GAME_DOWN_JING_CARD_LIST,\
    							names.GAME_LEFT_JING_CARD_LIST,\
    							names.GAME_RIGHT_JING_CARD_LIST
							}
end

function JingResultLayout:refresh_jing_result(jing_result_dict)
	jing_data_dict = jing_result_dict[names.GAME_JING_DATA_DICT] or {}
	hit_jing_dict = jing_result_dict[names.GAME_HIT_JING_DICT] or {}

    for key_name in pairs(self.__jing_key_list) do
    	jing_card_list = jing_data_dict[key_name]
    	if table.getn(jing_card_list) > 0 then
    		
    	end
    end
end