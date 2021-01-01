class RemoveAllFromGunclocks < ActiveRecord::Migration[5.0]
  def change
    remove_column :gunclocks, :size, :integer
    remove_column :gunclocks, :color, :string
  end
end
