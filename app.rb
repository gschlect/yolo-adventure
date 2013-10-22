require 'sinatra'
require 'sinatra/json'
require 'json'
require './config'


get '/samples' do
	if request.preferred_type == 'text/html'
		body "<h1>Html!</h1>"
	else
		json Sample.all
	end
end

get '/samples/:attr=:val' do
	# only allow requests that use a real param
	if Sample.column_names.include? params[:attr]
		samples = Sample.where(["#{params[:attr]} = ?", params[:val]])
		json samples
	else
		halt 400
	end
end

get '/samples/:id' do
	sample = Sample.find_by_id params[:id]
	unless sample.nil?
		sample.to_json.to_str
	else
		halt 404
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

