

begin
	
	import CSV
	import Gadfly
	import Gadfly.px
	import Cairo
	
	using DataFrames
	using Statistics
	using Formatting
	using Printf
	
end




(
	_dataset_path,
	_plot_path,
	_plot_format,
	_dataset_filter,
	_dataset_index,
	_dataset_metric,
) = ARGS

_dataset_filter = Symbol(_dataset_filter)
_dataset_index = Symbol(_dataset_index)
_dataset_metric = Symbol(_dataset_metric)
_plot_format = Symbol(_plot_format)




_dataset = CSV.read(
		_dataset_path,
		header = 1,
		normalizenames = true,
		delim = "\t", quotechar = '\0', escapechar = '\0',
		categorical = true,
		strict = true,
	)




_dataset = filter(
		(_data ->
			(_data[_dataset_index] !== missing) &&
			(_data[_dataset_metric] !== missing) &&
			(_data[_dataset_metric] != 0) &&
			(_data[:province] !== missing) &&
			(_data[:province] == "total")),
		_dataset,
	)




if _dataset_filter == :global
	
	_dataset_countries = [
			"China", "South Korea",
			"Italy", "Spain", "Germany", "France",
			"United States",
		]
	
	_dataset_smoothing = if (_dataset_metric in [
			:delta_recovered, :deltapct_recovered,
		]) nothing else 0.9 end
	
elseif _dataset_filter == :continents
	
	_dataset_countries = [
			
			"Asia", "Europe", "Americas",
			"Oceania", "Africa",
			
		]
	
	_dataset_smoothing = 0.9
	
elseif _dataset_filter == :subcontinents
	
	_dataset_countries = [
			"Western Asia", "Central Asia", "Southern Asia", "South-Eastern Asia", "Eastern Asia",
			"Western Europe", "Northern Europe", "Central Europe", "Southern Europe", "Eastern Europe",
			"North America", "Central America", "South America",
			"Western Africa", "Northern Africa", "Middle Africa", "Southern Africa", "Eastern Africa",
			"Australia and New Zealand", "Caribbean", "Melanesia", "Micronesia", "Polynesia",
		]
	
	_dataset_smoothing = 0.9
	
elseif _dataset_filter == :romania
	
	_dataset_countries = [
			"Romania",
			"Bulgaria", "Hungaria",
			"Italy", "Spain", "Germany", "France",
			"Austria", "Switzerland", "United Kingdom",
			"United States",
		]
	
	_dataset = filter(
			(_data -> _data[_dataset_index] <= 10),
			_dataset,
		)
	
	_dataset_smoothing = if (_dataset_metric in [
			:absolute_deaths, :relative_deaths, :delta_deaths, :deltapct_deaths,
			:absolute_recovered, :relative_recovered, :delta_recovered, :deltapct_recovered,
		]) nothing else 0.9 end
	
else
	throw(error("[698e83db]"))
end




_dataset = filter(
		(_data -> _data[:country] in _dataset_countries),
		_dataset,
	)

_dataset_countries = unique(_dataset[!, :country])

_dataset_countries = filter(
		(_country -> maximum(filter((_data -> _data[:country] == _country), _dataset)[!, _dataset_index]) >= 5),
		_dataset_countries,
	)

_dataset = filter(
		(_data -> _data[:country] in _dataset_countries),
		_dataset,
	)




_dataset_min_date = minimum(_dataset[!, :date])
_dataset_max_date = maximum(_dataset[!, :date])
_dataset_max_index = maximum(_dataset[!, _dataset_index])
_dataset_min_metric = minimum(_dataset[!, _dataset_metric])
_dataset_max_metric = maximum(_dataset[!, _dataset_metric])
_dataset_qmin_metric = quantile(_dataset[!, _dataset_metric], 0.01)
_dataset_qmax_metric = quantile(_dataset[!, _dataset_metric], 0.99)

if (abs(_dataset_min_metric - _dataset_qmin_metric) / _dataset_qmin_metric) > 0.25
	_dataset_min_metric = _dataset_qmin_metric
end
if (abs(_dataset_max_metric - _dataset_qmax_metric) / _dataset_qmax_metric) > 0.25
	_dataset_max_metric = _dataset_qmax_metric
end


_dataset_cmin_metric = nothing
_dataset_cmax_metric = nothing

if _dataset_metric in [:relative_recovered, :relative_deaths, :relative_infected]
	_dataset_rstep_metric = maximum([floor((_dataset_max_metric - _dataset_min_metric) / 10), 1])
	_dataset_cmin_metric = 0
	_dataset_cmax_metric = 100
	_dataset_rsuf_metric = "%"
elseif _dataset_metric in [:deltapct_confirmed, :deltapct_recovered, :deltapct_deaths, :deltapct_infected]
	_dataset_rstep_metric = maximum([floor((_dataset_max_metric - _dataset_min_metric) / 10), 1])
	_dataset_rsuf_metric = "%"
else
	_dataset_rstep_metric = 10 ^ maximum([floor(log10(_dataset_max_metric - _dataset_min_metric)), 0])
	_dataset_rsuf_metric = ""
end

_dataset_rmin_metric = floor(_dataset_min_metric / _dataset_rstep_metric) * _dataset_rstep_metric
_dataset_rmax_metric = ceil(_dataset_max_metric / _dataset_rstep_metric) * _dataset_rstep_metric

if _dataset_cmin_metric !== nothing
	_dataset_rmin_metric = maximum([_dataset_rmin_metric, _dataset_cmin_metric])
end
if _dataset_cmax_metric !== nothing
	_dataset_rmax_metric = minimum([_dataset_rmax_metric, _dataset_cmax_metric])
end




Gadfly.push_theme(:dark)


_plot_palette_20 = Gadfly.Scale.color_discrete().f(25)
_plot_palette_10 = Gadfly.Scale.color_discrete().f(10)

_plot_colors = DataFrame([
		
		"Romania" _plot_palette_20[1];
		"China" _plot_palette_20[2];
		"Italy" _plot_palette_20[3];
		"Spain" _plot_palette_20[4];
		"Germany" _plot_palette_20[5];
		"France" _plot_palette_20[6];
		"Austria" _plot_palette_20[7];
		"Switzerland" _plot_palette_20[8];
		"United Kingdom" _plot_palette_20[9];
		"United States" _plot_palette_20[10];
		"South Korea" _plot_palette_20[11];
		"Iran" _plot_palette_20[12];
		"Bulgaria" _plot_palette_20[13];
		"Hungaria" _plot_palette_20[14];
		
		"Asia" _plot_palette_10[1];
		"Europe"  _plot_palette_10[2];
		"Americas" _plot_palette_10[3];
		"Oceania" _plot_palette_10[4];
		"Africa" _plot_palette_10[5];
		
		"Western Asia" _plot_palette_20[1];
		"Central Asia" _plot_palette_20[2];
		"Southern Asia" _plot_palette_20[3];
		"South-Eastern Asia" _plot_palette_20[4];
		"Eastern Asia" _plot_palette_20[5];
		
		"Western Europe" _plot_palette_20[6];
		"Northern Europe" _plot_palette_20[7];
		"Central Europe" _plot_palette_20[8];
		"Southern Europe" _plot_palette_20[9];
		"Eastern Europe" _plot_palette_20[10];
		
		"North America" _plot_palette_20[11];
		"Central America" _plot_palette_20[12];
		"South America" _plot_palette_20[13];
		
		"Western Africa" _plot_palette_20[14];
		"Northern Africa" _plot_palette_20[15];
		"Middle Africa" _plot_palette_20[16];
		"Southern Africa" _plot_palette_20[17];
		"Eastern Africa" _plot_palette_20[18];
		
		"Australia and New Zealand" _plot_palette_20[19];
		"Caribbean" _plot_palette_20[20];
		"Melanesia" _plot_palette_20[21];
		"Micronesia" _plot_palette_20[22];
		"Polynesia" _plot_palette_20[23];
		
	])

_plot_colors = filter(
		(_color -> _color[1] in _dataset_countries),
		_plot_colors,
	)

_plot_colors_count = size(_plot_colors)[1]
_plot_colors[:,2] = circshift(Gadfly.Scale.color_discrete().f(_plot_colors_count), 1)


_plot_font_name = "JetBrains Mono"
_plot_font_size = 12px

_plot_style = Gadfly.style(
		point_size = 4px,
		line_width = 2px,
		grid_line_width = 1px,
		highlight_width = 1px,
		major_label_font = _plot_font_name,
		major_label_font_size = _plot_font_size,
		minor_label_font = _plot_font_name,
		minor_label_font_size = _plot_font_size,
		point_label_font = _plot_font_name,
		point_label_font_size = _plot_font_size,
		key_title_font = _plot_font_name,
		key_title_font_size = _plot_font_size * 0,
		key_label_font = _plot_font_name,
		key_label_font_size = _plot_font_size,
		key_position = :right,
		key_max_columns = 16,
		colorkey_swatch_shape = :circle,
		discrete_highlight_color = (_ -> nothing),
		plot_padding = [16px],
	)


_plot = Gadfly.plot(
		Gadfly.layer(
			_dataset,
			x = _dataset_index,
			y = _dataset_metric,
			color = :country,
			Gadfly.Geom.point,
			Gadfly.style(discrete_highlight_color = (_ -> "black")),
		),
		Gadfly.layer(
			_dataset,
			x = _dataset_index,
			y = _dataset_metric,
			color = :country,
			if _dataset_smoothing !== nothing
				Gadfly.Geom.smooth(method = :loess, smoothing = _dataset_smoothing)
			else
				Gadfly.Geom.line
			end,
		),
		Gadfly.Coord.cartesian(xmin = 1, xmax = _dataset_max_index, ymin = _dataset_rmin_metric, ymax = _dataset_rmax_metric),
		Gadfly.Scale.x_continuous(format = :plain, labels = (_value -> @sprintf("%d", _value))),
		Gadfly.Scale.y_continuous(format = :plain, labels = (_value -> format(_value, commas = true) * _dataset_rsuf_metric)),
		Gadfly.Guide.title(@sprintf("JHU CSSE COVID-19 dataset -- `%s` per `%s` (until %s)", _dataset_metric, _dataset_index, _dataset_max_date)),
		Gadfly.Guide.xlabel(nothing),
		Gadfly.Guide.ylabel(nothing),
		Gadfly.Guide.xticks(ticks = [1; 5 : 5 : _dataset_max_index;]),
		Gadfly.Guide.yticks(ticks = [_dataset_rmin_metric : _dataset_rstep_metric : _dataset_rmax_metric;]),
		Gadfly.Scale.color_discrete_manual(_plot_colors[:,2]..., levels = _plot_colors[:,1]),
		_plot_style,
	)




if _plot_format == :pdf
	_plot_output = Gadfly.PDF(_plot_path, 800px, 400px)
else
	throw(error("[14de0af5]"))
end

Gadfly.draw(_plot_output, _plot)

