# DeleteResult
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

require 'zuora/error'

module Zuora

  class DeleteResult

    attr_accessor :errors, :id, :success

    def initialize(delete_result)
      @errors = []
      Array.wrap(delete_result[:errors]).each do |error|
        @errors << Zuora::Error.new(error[:code], error[:field], 
            error[:message])
      end
      @id = delete_result[:id]
      @success = delete_result[:success]
    end

  end

end