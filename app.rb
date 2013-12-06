require 'sinatra'
require 'sinatra/json'
require 'json'
require 'haml'
require "net/http"
require "uri"
require './config'

def getWeather(sample)
	f = ForecastIO.forecast(sample.latitude, sample.longitude, {:time => sample.date_collected.to_time.to_i})
	if f.nil? or f.daily.nil?
		return nil
	else
		return f.daily.data[0]
	end
end


get '/setup' do
	Sample.create(:species => 'Maple', :notes => 'Ex dolorem accumsan voluptaria eum. Ea vel soleat officiis luptatum, ut eum porro partem voluptatum, probatus oportere percipitur eu duo.', :latitude => 46, :longitude => -117, :date_collected => '2012-06-15')
	Sample.create(:species => 'Fir', :notes => 'Usu ea scripta detracto repudiare. Nam id quidam suscipiantur, recteque salutatus ne sea, sed in labitur prodesset.', :latitude => 43, :longitude => -120, :date_collected => '2012-07-01')
	Sample.create(:species => 'Spruce', :notes => 'Inani fastidii et vix, ut duo debitis accusata. Omnes possit duo ex, no elitr iuvaret his, sale option nusquam est in.', :latitude => 42, :longitude => -119, :date_collected => '2012-08-16')
	Sample.create(:species => 'Birch', :notes => 'Ex magna harum sed, sit id veritus suscipit. Te soluta suscipit vis. Altera melius propriae sit ad, cum an novum liber aliquid, mei et virtute sapientem.', :latitude => 51, :longitude => -100, :date_collected => '2011-05-09')
	Sample.create(:species => 'Pine', :notes => 'Lorem ipsum dolor sit amet, an munere doming expetendis est. Vis viderer singulis aliquando et, an pro detraxit suscipiantur conclusionemque. Augue vocibus ut vis, id cum impetus scripta dolores, deleniti gubergren delicatissimi te usu. Mel ea nulla feugait, eam ex recteque gloriatur, ne brute volutpat mel.', :latitude => 55, :longitude => -110, :date_collected => '2012-01-15')
	Sample.create(:species => 'Oak', :notes => 'Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit...', :latitude => 24, :longitude => -123, :date_collected => '2012-12-12')
	Sample.create(:species => 'Fir', :notes => 'Another fir sample! We got two.', :latitude => 33, :longitude => -109, :date_collected => '2012-03-23')
	Sample.create(:species => 'Pine', :notes => 'This is a long note, that has something to do with this interesting sample of pine. This sample was taken from a strange time and place, so we don\'t have weather data for it.', :latitude => 175, :longitude => 175, :date_collected => '2013-12-04')
	redirect to('/samples')
end

get '/reset' do
	Sample.delete_all
	redirect to('/samples')
end

get '/' do
	redirect to('/samples')
end

get '/samples.?:format?' do
	filters = request.env['rack.request.query_hash']

	if (filters.keys - Sample.column_names).empty?
		samples = Sample.all(:conditions => filters)

		if params[:format] == 'json'
			json samples
		else
			@samples = samples
			@species = request[:species] || 'All'
			haml :sample_list
		end
	else
		halt 400
	end
end

post '/samples' do
	# parse the data
	begin
		data = JSON.parse request.body.read
	rescue JSON::ParserError
		halt 400
	end

	# create a new sample
	if (Sample.column_names - (data.keys << 'id')).empty?
		Sample.create data
		status 201
	else
		status 400
	end

end

delete '/samples.?:format?' do 
	filters = request.env['rack.request.query_hash']

	if (filters.keys - Sample.column_names).empty?
		Sample.destroy_all(filters)
		halt 204
	else
		halt 400
	end
end

get '/samples/:id.?:format?' do
	sample = Sample.find_by_id params[:id]

	if sample.nil?
		halt 404
	end

	if params[:format] == 'json'
		json sample
	else
		@sample = sample
		@weather = getWeather(sample)
		haml :sample_details
	end
end

delete '/samples/:id.?:format?' do 
	sample = Sample.find_by_id params[:id]

	if sample.nil?
		halt 404
	end

	sample.destroy
	halt 204
end

# clean up db connection for each request
after do
	ActiveRecord::Base.connection.close
end

__END__

@@ sample_list
%html
	%head
		%title= 'Samples'
		%link{:href => '//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css', :rel => 'stylesheet'}
		%link{:href => '/app.css', :rel => 'stylesheet'}
		%script{:src => 'http://code.jquery.com/jquery-2.0.3.min.js'}
		%script{:src => '/jquery.sortElements.js'}
		%script{:src => '/sort.js'}
		%meta{:name => 'viewport', :content => 'width=device-width; initial-scale=1.0; maximum-scale=1.0; minimum-scale=1.0; user-scalable=0;'}

	%body
		%h3= 'Samples'

		%ul.nav.nav-pills
			%li{:class => (@species == 'All' ? 'active' : '')}
				%a{:href => "/samples"}= 'All'
			- Sample.select(:species).distinct.each do |s|
				%li{:class => (s.species == @species ? 'active' : '')}
					%a{:href => "/samples?species=#{s.species}"}= s.species
		%div.table-responsive
			%table.table.table-bordered.sortable{:style => 'table-layout: fixed'}
				%thead
					%tr
						%th.sort{:style => 'width: 65px;'}
							:plain
								#
							%span.glyphicon.glyphicon-chevron-up.pull-right
						%th{:style => 'width: 125px;'}
							Date
							%span.glyphicon.glyphicon-chevron-up.pull-right
						%th{:style => 'width: 180px;'}
							Species
							%span.glyphicon.glyphicon-chevron-up.pull-right
						%th{:style => 'min-width: 200px;'}
							Notes
							%span.glyphicon.glyphicon-chevron-up.pull-right
						%th{:style => 'width: 78px;'}
							Latitude
							%span.glyphicon.glyphicon-chevron-up.pull-right
						%th{:style => 'width: 93px;'}
							Longitude
							%span.glyphicon.glyphicon-chevron-up.pull-right
				%tbody
				- @samples.each do |s|
					%tr
						%td
							%a{:href => "/samples/#{s.id}"}= s.id
						%td{'data-sortval' => s.date_collected}= s.date_collected.strftime('%b %-d, %Y')
						%td= s.species
						%td.truncate= s.notes
						%td= s.latitude
						%td= s.longitude

@@ sample_details
%html
	%head
		%title= 'Sample'
		%link{:href => '//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css', :rel => 'stylesheet'}
		%link{:href => '/app.css', :rel => 'stylesheet'}
		%meta{:name => 'viewport', :content => 'width=device-width; initial-scale=1.0; maximum-scale=1.0; minimum-scale=1.0; user-scalable=0;'}
		%script{:src => 'https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false'}
		:javascript
			function init() {
				var latlong = new google.maps.LatLng(#{@sample.latitude}, #{@sample.longitude}),
				mapOptions = {
					zoom: 8,
					center: latlong,
					mapTypeId: google.maps.MapTypeId.HYBRID
				},
				marker = new google.maps.Marker({
					position: latlong,
					title: 'Sample'
				}),
				map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

				marker.setMap(map);

				document.getElementById('qrcode').src += window.location.href;
			}
			google.maps.event.addDomListener(window, 'load', init);

	%body
		%h3.print= @sample.species
		%h4.print{:style => 'display: none;'}= "Sample ID: #{@sample.id}"
		%p= @sample[:date_collected].strftime('%B %-d, %Y')
		- if not @weather.nil?
			%img.weatherimg{:width => '64px', :src => "/svg/#{@weather.icon}.svg"}
			%span.temp
				= @weather.temperatureMax.round
				%span.temp-label= "&deg;F"
			%p= @weather.summary
			%p{:style => 'font-size: 11px; font-style: italic; margin-top: -10px;'}
				Powered By 
				%a{:href => 'http://forecast.io/', :target => '_blank'}
					Forecast
		- else
			%p
				Weather Data Unavailable
		%h4{:style => 'margin-top: 20px; margin-bottom: 0px;'}
			Notes:
		%p.notes= @sample.notes
		%a#printer.btn.btn-default{:href => '#', :onclick => 'window.print()'}
			%span.glyphicon.glyphicon-print
			Print Label
		%img#qrcode.print{:src => '//chart.apis.google.com/chart?cht=qr&chs=200x200&chld=H|0&chl=', :style => 'display: none;'}
		%h5= "#{@sample.latitude.abs}&deg; #{@sample.latitude > 0 ? 'N' : 'S'}, #{@sample.longitude.abs}&deg; #{@sample.longitude > 0 ? 'E' : 'W'}"
		#map-canvas
