map ({key : .aliases[], value : .code})
| group_by (.key)
| map (
	if ((. | length) == 1) then
		.[0]
	else
#		["783ec68b", .] | debug |
		empty
	end)
| (. + (
	{
		
		# NOTE:  From JHU dataset.
		"bahamas_the" : "BS",
		"cote_d_ivoire" : "CI",
		"gambia_the" : "GM",
		"guyana" : "GY",
		"holy_see" : "VA",
		"korea_south" : "KR",
		"sudan" : "SD",
		"cruise_ship" : "XX",
		"the_bahamas" : "BS",
		"the_gambia" : "GM",
		"occupied_palestinian_territory" : "PS",
		"the_west_bank_and_gaza" : "PS",
		"west_bank_and_gaza" : "PS",
		"mainland_china" : "CN",
		"north_ireland" : "GB",
		"st_martin" : "MF",
		"channel_islands" : "XX", # ???
		"uk" : "GB",
		"taipei_and_environs" : "TW", # ???
		"hong_kong_sar" : "HK",
		"macao_sar" : "MO",
		"others" : "XX",
		"fench_guiana" : "GF",
		
		# NOTE:  From ECDC dataset.
		"curaao" : "CW",
		"cote_divoire" : "CI",
		"cases_on_an_international_conveyance_japan" : "JP",
		"bonaire" : "BQ",
		"bonaire_saint_eustatius_and_saba" : "BQ",
		
		# NOTE:  From CIA factbook.
		"congo_democratic_republic_of_the" : "CD",
		"congo_republic_of_the" : "CG",
		"korea_north" : "KP",
		"macedonia" : "MK",
		"saint_martin" : "MF",
		"saint_barthelemy" : "BL",
		"paracel_islands" : "XX",
		"holy_see_vatican_city" : "VA",
		"falkland_islands_islas_malvinas" : "FK",
		"gaza_strip" : "PS",
		"west_bank" : "PS",
		
	}
	| to_entries
))
| sort_by (.value)
| from_entries
