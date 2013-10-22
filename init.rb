require './config'

ActiveRecord::Schema.define do
	create_table(:samples) do |t|
		t.string :species
		t.text :notes
	end
end

Sample.create(:species => 'Maple', :notes => 'Nothing interesting.')
Sample.create(:species => 'Fir', :notes => 'A bit interesting.')
Sample.create(:species => 'Spruce', :notes => 'Boring.')
Sample.create(:species => 'Birch', :notes => 'This was a bad sample.')
Sample.create(:species => 'Pine', :notes => 'This was a good sample.')
Sample.create(:species => 'Oak', :notes => 'Very strong.')
Sample.create(:species => 'Fir', :notes => 'Another fir sample!')
