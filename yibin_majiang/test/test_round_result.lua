round_data_str = [[
	{
    "game_ming_gang_point_dict": {
        "10000": 0,
        "10001": 0,
        "10002": 0,
        "10003": 0
    },
    "account_data": {
        "10000": {
            "account_last_peng_list": [],
            "account_handcard": [
                102,
                105,
                105,
                105,
                108,
                108,
                208,
                208,
                209,
                308
            ],
            "account_hu_conbination_list": [],
            "account_last_chi_list": [],
            "account_change_chip": 586,
            "account_last_an_gang_list": [
                104
            ],
            "account_chip": 20586,
            "account_last_ming_gang_list": [],
            "account_last_fang_gang_dict": {}
        },
        "10001": {
            "account_last_peng_list": [],
            "account_handcard": [
                101,
                101,
                101,
                201,
                201,
                201,
                401,
                401,
                401,
                404,
                405,
                406,
                407
            ],
            "account_hu_conbination_list": [
                [
                    "10000",
                    [
                        "xiaohu",
                        "dg",
                        "dh"
                    ],
                    407
                ]
            ],
            "account_last_chi_list": [],
            "account_change_chip": -194,
            "account_last_an_gang_list": [],
            "account_chip": 19806,
            "account_last_ming_gang_list": [],
            "account_last_fang_gang_dict": {}
        },
        "10002": {
            "account_last_peng_list": [],
            "account_handcard": [
                103,
                109,
                201,
                204,
                205,
                205,
                206,
                207,
                208,
                301,
                301,
                303,
                305
            ],
            "account_hu_conbination_list": [],
            "account_last_chi_list": [],
            "account_change_chip": -196,
            "account_last_an_gang_list": [],
            "account_chip": 19804,
            "account_last_ming_gang_list": [],
            "account_last_fang_gang_dict": {}
        },
        "10003": {
            "account_last_peng_list": [],
            "account_handcard": [
                101,
                103,
                106,
                106,
                202,
                203,
                204,
                207,
                209,
                301,
                301,
                302,
                309
            ],
            "account_hu_conbination_list": [],
            "account_last_chi_list": [],
            "account_change_chip": -196,
            "account_last_an_gang_list": [],
            "account_chip": 19804,
            "account_last_ming_gang_list": [],
            "account_last_fang_gang_dict": {}
        }
    },
    "game_hu_point_dict": {
        "10000": 4,
        "10001": 0,
        "10002": -2,
        "10003": -2
    },
    "game_jing_point_dict": {
        "game_up_jing_card_list": {
            "10000": 231,
            "10001": -77,
            "10002": -77,
            "10003": -77
        },
        "game_down_jing_card_list": {
            "10000": 231,
            "10001": -77,
            "10002": -77,
            "10003": -77
        }
    },
    "game_hit_jing_dict": {
        "game_up_jing_card_list": {
            "10000": [
                4,
                3
            ],
            "10001": [
                0,
                0
            ],
            "10002": [
                0,
                0
            ],
            "10003": [
                0,
                0
            ]
        },
        "game_down_jing_card_list": {
            "10000": [
                4,
                3
            ],
            "10001": [
                0,
                0
            ],
            "10002": [
                0,
                0
            ],
            "10003": [
                0,
                0
            ]
        }
    },
    "game_pass_off_jing_dict": {
        "game_up_jing_card_list": {
            "10000": 7
        },
        "game_down_jing_card_list": {
            "10000": 7
        }
    },
    "game_ba_jing_dict": {
        "game_up_jing_card_list": "10000",
        "game_down_jing_card_list": "10000"
    },
    "game_jing_data_dict": {
        "game_up_jing_card_list": [
            104,
            105
        ],
        "game_down_jing_card_list": [
            104,
            105
        ]
    },
    "game_gang_jing_dict": {
        "10000": [
            104,
            104
        ]
    },
    "game_gang_jing_point_dict": {
        "10000": 60,
        "10001": -20,
        "10002": -20,
        "10003": -20
    },
    "game_an_gang_point_dict": {
        "10000": 6,
        "10001": -2,
        "10002": -2,
        "10003": -2
    }
}
]]

function get_round_result()
	mrequire("json")
	local round_table = json.decode(round_data_str)
	print("--------get_round_result")
	dump(round_table)
	return round_table
end