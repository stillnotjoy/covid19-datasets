(
	[
		
		"location_key",
		"location_label",
		"country",
		"province",
		"location_lat",
		"location_long",
		
		"date",
		"day_index_1",
		"day_index_10",
		"day_index_100",
		"day_index_1000",
		
		"absolute_confirmed",
		"absolute_deaths",
		"absolute_recovered",
		"absolute_infected",
		
		"relative_confirmed",
		"relative_deaths",
		"relative_recovered",
		"relative_infected",
		
		"delta_confirmed",
		"delta_deaths",
		"delta_recovered",
		"delta_infected",
		
		"deltapct_confirmed",
		"deltapct_deaths",
		"deltapct_recovered",
		"deltapct_infected"
		
	]
	| join ("\t")
	
) , (
	
	.[]
	| (
		[
		
			.location.key,
			.location.label,
			.location.country,
			.location.province,
			.location.lat_long[0],
			.location.lat_long[1],
			
			.date.date,
			.day_index_1,
			.day_index_10,
			.day_index_100,
			.day_index_1000
			
		] + [
			
			.values
			| (.absolute, .relative, .delta, .delta_pct)
			| (.confirmed, .deaths, .recovered, .infected)
			
		]
	)
	| map (if (. != null) then tostring else "" end)
	| join ("\t")
	
)
