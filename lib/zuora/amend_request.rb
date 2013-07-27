# AmendRequest
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

require 'builder'
require 'zuora/zobject'
require 'gyoku'

module Zuora

  class AmendRequest
    
    attr_accessor :amendment, :amend_options, :preview_options
    
    def initialize(amendment, amend_options = {}, preview_options = {})
      @amendment = amendment
      @amend_options = amend_options
      @preview_options = preview_options
    end
    
    def to_xml
      xml = Builder::XmlMarkup.new
      amendment, amend_options, preview_options = 
          @amendment, @amend_options, @preview_options
      xml.api :requests, { "xmlns:api" => "http://api.zuora.com/" } do |xml|
        xml << amendment.to_xml("api:Amendments")
        xml.api :AmendOptions do |xml|
          xml << Gyoku.xml(amend_options, :key_converter => :camelcase)
        end
        xml.api :PreviewOptions do |xml|
          xml << Gyoku.xml(preview_options, :key_converter => :camelcase)
        end
      end
      xml.target!
    end
    
  end
  
end