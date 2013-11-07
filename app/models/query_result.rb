class QueryResult < ActiveRecord::Base
  attr_accessible :query, :header_row, :data_rows
  serialize :header_row
  serialize :data_rows
  belongs_to :connector
end
