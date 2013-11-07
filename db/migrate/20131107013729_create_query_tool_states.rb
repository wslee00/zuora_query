class CreateQueryToolStates < ActiveRecord::Migration
  def change
    create_table :query_tool_states do |t|
      t.references :last_connector_id

      t.timestamps
    end
  end
end
