class Connector < ActiveRecord::Base
  attr_accessible :name, :password, :connector_type, :url, :username

end
