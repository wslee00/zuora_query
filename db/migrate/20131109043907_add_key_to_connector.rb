class AddKeyToConnector < ActiveRecord::Migration
  def change
    add_column :connectors, :key, :string
  end
end
