class AddFieldsToConnector < ActiveRecord::Migration
  def change
    add_column :connectors, :num_limit, :integer
    add_column :connectors, :order_by_field, :string
    add_column :connectors, :order_by_direction, :string
  end
end
