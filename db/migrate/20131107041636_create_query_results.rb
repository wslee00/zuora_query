class CreateQueryResults < ActiveRecord::Migration
  def change
    create_table :query_results do |t|
      t.references :connector  
      t.text :query
      t.text :header_row
      t.text :data_rows
      t.timestamps
    end
  end
end
