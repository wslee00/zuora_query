class UpdateConnectorsChangeType < ActiveRecord::Migration
  def change
    add_column :connectors, :connector_type, :string
    remove_column :connectors, :type
  end
end
