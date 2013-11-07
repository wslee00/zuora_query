class AddWindowStateToConnector < ActiveRecord::Migration
  def change
    add_column :connectors, :window_state, :text
  end
end
