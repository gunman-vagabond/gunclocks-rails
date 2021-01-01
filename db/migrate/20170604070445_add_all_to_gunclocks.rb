class AddAllToGunclocks < ActiveRecord::Migration[5.0]
  def change
    add_column :gunclocks, :size, :integer
    add_column :gunclocks, :color, :string
  end
end
