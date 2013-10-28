require './config'

ActiveRecord::Schema.define do
	create_table(:samples) do |t|
		t.string :species
		t.text :notes
		t.decimal :latitude
		t.decimal :longitude
	end
end

