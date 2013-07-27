# QueryResult
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

module Zuora

  class QueryResult

    attr_accessor :done, :query_locator, :records, :size

    def initialize(query_response)
      query_result = query_response.to_hash[:query_response][:result] if
            query_response.to_hash.has_key?(:query_response)
      query_result = query_response.to_hash[:query_more_response][:result] if
            query_response.to_hash.has_key?(:query_more_response)
      @done = query_result[:done]
      @query_locator = query_result[:query_locator]
      @size = query_result[:size].to_i
      @records = []
      Array.wrap(query_result[:records]).each do |record|
        @records.push ZObject.new(record)
      end
    end

  end
  
end