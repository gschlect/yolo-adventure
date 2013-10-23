require 'sinatra'
require 'sinatra/json'
require 'json'
require 'haml'
require './config'

get '/samples' do
	@samples = Sample.all
	if request.accept? 'text/html'
		haml :sample_list
	else
 		json @samples
	end
end

get '/samples/:attr=:val' do
	# only allow requests that use a real param
	if Sample.column_names.include? params[:attr]
		@samples = Sample.where(["#{params[:attr]} = ?", params[:val]])
	else
		halt 400
	end

	if request.accept? 'text/html'
		haml :sample_list
	else
 		json @samples
	end
end

get '/samples/:id' do
	@sample = Sample.find_by_id params[:id]
	if @sample.nil?
		halt 404
	end

	if request.accept? 'text/html'
		haml :sample_details
	else
 		json @sample
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
	json :uri => "http://localhost:4567/samples/#{sample.id}"
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
%body{:style => 'padding: 20px 50px'}
	%table.table
		%thead
			%tr
				%th= '#'
				%th= 'Species'
				%th= 'Notes'
				%th= 'Latitude'
				%th= 'Longitude'
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
		%script{:src => '/qrcode.min.js'}
		%script{:src => 'https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false'}
		:javascript
			function initCanvases() {
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

				new QRCode(document.getElementById('qr-canvas'), {
					text: window.location.href,
					width: 100,
					height: 100
				});
			}
			google.maps.event.addDomListener(window, 'load', initCanvases);

	%body{:style => 'padding: 20px 50px'}
		%h3= @sample.species
		%p= @sample.notes
		#qr-canvas{:style => 'height: 100px'}
		%h5= "#{@sample.latitude.abs}&deg; #{@sample.latitude > 0 ? 'N' : 'S'}, #{@sample.longitude.abs}&deg; #{@sample.longitude > 0 ? 'E' : 'W'}"
		#map-canvas{:style => 'height: 400px'}