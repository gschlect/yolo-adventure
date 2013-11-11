class AddDate < ActiveRecord::Migration
	def up
		add_column :samples, :date_collected, :date
	end

	def down
		remove_column :samples, :date_collected
	end
end
