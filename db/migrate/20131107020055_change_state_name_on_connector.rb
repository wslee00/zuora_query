class ChangeStateNameOnConnector < ActiveRecord::Migration
  def up
    add_column :connectors, :editor_state, :text
  end

  def down
    remove_column :connectors, :editor_state
  end
end
