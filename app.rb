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
		%script{:src => 'http://code.jquery.com/jquery-2.0.3.min.js'}
		%script{:src => 'jquery.sortElements.js'}
		:css
			.glyphicon {
				display: none;
			}
			th.sort > .glyphicon {
				display: inline-block;
			}
			th {
				cursor: pointer;
			}
		:javascript
			function isNumeric(n) {
				return !isNaN(parseFloat(n)) && isFinite(n);
			}

			function sort($th){
				var inverse = $th.children('.glyphicon').hasClass('glyphicon-chevron-down');
				$('tbody')
					.find('td')
					.filter(function(){return $(this).index() === $th.index()})
					.sortElements(function(a, b){
						a = $.text([a]);
						b = $.text([b]);
						if(isNumeric(a) && isNumeric(b)){
							a = parseFloat(a);
							b = parseFloat(b);
						}
						if(a == b)
							return 0;
						else if(a > b)
							return (inverse ? -1 : 1);
						else
							return (inverse ? 1 : -1);
					}, function(){
						return this.parentNode;
					});
			}

			$(document).on('ready', function(){
				$('thead').on('click', 'th:not(.sort)', function(e){
					e.stopPropagation();
					$(this)
						.addClass('sort')
						.siblings()
						.removeClass('sort');
					sort($(this));
				})

				$('table').on('click', 'th.sort', function(){
					$(this)
						.children('.glyphicon')
						.toggleClass('glyphicon-chevron-up')
						.toggleClass('glyphicon-chevron-down');
					sort($(this));
				})
			});

%body{:style => 'padding: 20px 50px'}
	%table.table.table-hover.table-bordered
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
		:css
			@media print {
				body .print {
					display: block !important;
				}
				body * {
					display: none !important;
				}
			}
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

	%body{:style => 'padding: 20px 50px'}
		%h3.print= @sample.species
		%p= @sample.notes
		%a.btn.btn-default{:href => '#', :onclick => 'window.print()', :style => 'position: absolute; right: 50px; top: 45px;'}
			%span.glyphicon.glyphicon-print
			Print Label
		%img#qrcode.print{:src => '//chart.apis.google.com/chart?cht=qr&chs=200x200&chld=H|0&chl=', :style => 'display: none;'}
		%h5= "#{@sample.latitude.abs}&deg; #{@sample.latitude > 0 ? 'N' : 'S'}, #{@sample.longitude.abs}&deg; #{@sample.longitude > 0 ? 'E' : 'W'}"
		#map-canvas{:style => 'height: 400px'}