# AmendResult
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

module Zuora

  class AmendResult
    
    attr_accessor :amendment_ids, :errors, :invoice_datas, :invoice_id,
        :payment_transaction_number, :success
        
    def initialize(amend_result)
      @amendment_ids = []
      Array.wrap(amend_result[:amendment_ids]).each do |amendment_id|
        @amendment_ids << amendment_id
      end
      @errors = []
      Array.wrap(amend_result[:errors]).each do |error|
        @errors << Zuora::Error.new(error[:code], error[:field], 
            error[:message])
      end
      @invoice_datas = amend_result[:invoice_datas]
      @invoice_id = amend_result[:invoice_id]
      @payment_transaction_number = amend_result[:payment_transaction_number]
      @success = amend_result[:success]
    end
    
  end

end