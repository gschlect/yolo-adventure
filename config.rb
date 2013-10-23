require 'active_record'
require 'sqlite3'

configure :development do
	ActiveRecord::Base.establish_connection(
		:adapter  => :sqlite3,
		:database => "samples.sqlite3" 
	)
end

configure :production do
	ActiveRecord::Base.establish_connection(
		:adapter  => 'postgresql'
		:host     => 'ec2-54-204-20-28.compute-1.amazonaws.com',
		:username => 'cmamqqatznstsf',
		:password => 'DlAuxi2SD3oViwpeIq4Zmrs3ad',
		:port 	  => '5432'
		:database => 'd7n9rdqjt4bpt4'
	)
end

configure do
	ActiveRecord::Schema.define do
		create_table(:samples) do |t|
			t.string :species
			t.text :notes
			t.decimal :latitude
			t.decimal :longitude
		end
	end

	Sample.create(:species => 'Maple', :notes => 'Nothing interesting.', :latitude => 46, :longitude => -117)
	Sample.create(:species => 'Fir', :notes => 'A bit interesting.', :latitude => 43, :longitude => -120)
	Sample.create(:species => 'Spruce', :notes => 'Boring.', :latitude => 42, :longitude => -119)
	Sample.create(:species => 'Birch', :notes => 'This was a bad sample.', :latitude => 51, :longitude => -100)
	Sample.create(:species => 'Pine', :notes => 'This was a good sample.', :latitude => 55, :longitude => -110)
	Sample.create(:species => 'Oak', :notes => 'Very strong.', :latitude => 24, :longitude => -123)
	Sample.create(:species => 'Fir', :notes => 'Another fir sample!', :latitude => 33, :longitude => -109)
end

class Sample < ActiveRecord::Base
end