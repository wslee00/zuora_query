# SaveResult
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

require 'zuora/error'

module Zuora

  class SaveResult

    attr_accessor :errors, :id, :success

    def initialize(save_result)
      @errors = []
      Array.wrap(save_result[:errors]).each do |error|
        @errors << Zuora::Error.new(error[:code], error[:field], 
            error[:message])
      end
      @id = save_result[:id]
      @success = save_result[:success]
    end

  end

end