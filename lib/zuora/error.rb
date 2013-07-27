# Error
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

module Zuora

  class Error

    attr_accessor :code, :field, :message
    
    def initialize(code, field, message)
      @code = code
      @field = field
      @message = message
    end

    def to_s
      "ERROR: #{@message}" + (@field ? " [#{@field}]" : "") + " (#{@code})"
    end
    
  end

end