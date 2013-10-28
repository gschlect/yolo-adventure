class CreateSamples < ActiveRecord::Migration
	def up
  		create_table :samples do |t|
			t.string :species
			t.text :notes
			t.decimal :latitude
			t.decimal :longitude
		end
	end

	def down
		drop_table :samples
	end
end
