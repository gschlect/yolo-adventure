require './config'

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
