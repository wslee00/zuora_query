class ChangeQueryToolState < ActiveRecord::Migration
  def up
    remove_column :query_tool_states, :last_connector_id_id
    add_column :query_tool_states, :last_connector_id, :integer
  end

  def down
    remove_column :query_tool_states, :last_connector_id
  end
end
