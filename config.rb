require 'sinatra'
require 'sinatra/activerecord'

if ENV['HEROKU']
	require 'pg'
	ActiveRecord::Base.establish_connection(
		:adapter	=> :postgresql,
		:encoding	=> unicode,
		:pool		=> 5,
		:database	=> 'd7n9rdqjt4bpt4',
		:username	=> 'cmamqqatznstsf',
		:password	=> 'DlAuxi2SD3oViwpeIq4Zmrs3ad',
		:host		=> 'ec2-54-204-20-28.compute-1.amazonaws.com',
		:port		=> 5432
	)
else
	require 'sqlite3'
	ActiveRecord::Base.establish_connection(
		:adapter  => :sqlite3,
		:database => "db/samples.sqlite3" 
	)
end


class Sample < ActiveRecord::Base
end
