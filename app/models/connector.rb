class Connector < ActiveRecord::Base
  attr_accessible :name, :password, :connector_type, :url, :username, :editor_state, 
    :num_limit, :order_by_field, :order_by_direction

  has_many :query_results
end
