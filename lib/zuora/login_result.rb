# LoginResult
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

module Zuora
  
  class LoginResult

    attr_accessor :session, :server_url

    def initialize(login_response)
      login_result = login_response.to_hash[:login_response][:result]
      @session = login_result[:session]
      @server_url = login_result[:server_url]
    end

  end

end