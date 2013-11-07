class AddNameToConnectors < ActiveRecord::Migration
  def change
    add_column :connectors, :name, :string
  end
end
