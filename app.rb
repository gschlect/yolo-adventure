require 'sinatra'
require 'sinatra/json'
require 'json'
require 'haml'
require './config'

get '/setup' do
	Sample.create(:species => 'Maple', :notes => 'Nothing interesting.', :latitude => 46, :longitude => -117)
	Sample.create(:species => 'Fir', :notes => 'A bit interesting.', :latitude => 43, :longitude => -120)
	Sample.create(:species => 'Spruce', :notes => 'Boring.', :latitude => 42, :longitude => -119)
	Sample.create(:species => 'Birch', :notes => 'This was a bad sample.', :latitude => 51, :longitude => -100)
	Sample.create(:species => 'Pine', :notes => 'This was a good sample.', :latitude => 55, :longitude => -110)
	Sample.create(:species => 'Oak', :notes => 'Very strong.', :latitude => 24, :longitude => -123)
	Sample.create(:species => 'Fir', :notes => 'Another fir sample!', :latitude => 33, :longitude => -109)
	"Added some samples"
end

get '/reset' do
	Sample.delete_all
	"Removed all samples"
end

get '/samples.?:format?' do
	filters = request.env['rack.request.query_hash']

	if (filters.keys - Sample.column_names).empty?
		samples = Sample.find(:all, :conditions => filters)

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
	Sample.create data
	status 201
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

		%table.table.table-hover.table-bordered.sortable
			%thead
				%tr
					%th.sort
						:plain
							#
						%span.glyphicon.glyphicon-chevron-up.pull-right
					%th
						:plain
							Species
						%span.glyphicon.glyphicon-chevron-up.pull-right
					%th
						:plain
							Notes
						%span.glyphicon.glyphicon-chevron-up.pull-right
					%th
						:plain
							Latitude
						%span.glyphicon.glyphicon-chevron-up.pull-right
					%th
						:plain
							Longitude
						%span.glyphicon.glyphicon-chevron-up.pull-right
			%tbody
			- @samples.each do |s|
				%tr
					%td
						%a{:href => "/samples/#{s.id}"}= s.id
					%td= s.species
					%td= s.notes
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
		%p= @sample.notes
		%a#printer.btn.btn-default{:href => '#', :onclick => 'window.print()'}
			%span.glyphicon.glyphicon-print
			Print Label
		%img#qrcode.print{:src => '//chart.apis.google.com/chart?cht=qr&chs=200x200&chld=H|0&chl=', :style => 'display: none;'}
		%h5= "#{@sample.latitude.abs}&deg; #{@sample.latitude > 0 ? 'N' : 'S'}, #{@sample.longitude.abs}&deg; #{@sample.longitude > 0 ? 'E' : 'W'}"
		#map-canvas