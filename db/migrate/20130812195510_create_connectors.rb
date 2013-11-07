class CreateConnectors < ActiveRecord::Migration
  def change
    create_table :connectors do |t|
      t.string :username
      t.string :password
      t.string :type
      t.string :url

      t.timestamps
    end
  end
end
