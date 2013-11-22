# Ruby client for Zuora
#
# Author:: David Massad (mailto:david.massad@fronteraconsulting.net)
# Copyright:: Copyright (c) 2013 Frontera Consulting
# License:: Not to be used or distributed without written consent from Frontera Consulting.

require 'savon'
require 'builder'
require 'net/http'
require 'fire_poll'
require 'zuora/zobject'
require 'nori'

module Zuora

  class Client

    ZUORA_API_VERSION = "50.0"
    ZUORA_WSDL_LOCATION = "../zuora-48.0-production-AllOptions.wsdl"

    attr_accessor :query_batch_size, :show_logs

    def initialize(username, password, endpoint_base)
      @query_batch_size = 100
      @username, @password, @endpoint_base = username, password, endpoint_base
      @endpoint = "#{@endpoint_base}/apps/services/a/#{ZUORA_API_VERSION}"
      @client = Savon.client(endpoint: @endpoint, wsdl: File.expand_path(ZUORA_WSDL_LOCATION, __FILE__))
      login
    end
    
    def amend(amend_request)
      amend_response = @client.call(:amend, message: amend_request.to_xml)
      amend_results = Array.wrap(amend_response.to_hash[:amend_response][:results])
      results = []
      amend_results.each do |amend_result|
        results << AmendResult.new(amend_result)
      end
      results
    end

    def create(zobjects, type_name) 
      zobjects_xml = build_zobjects_xml(zobjects, type_name)
      save_response = @client.call(:create, message: zobjects_xml)
      save_results = Array.wrap(save_response.to_hash[:create_response][:result])
      results = []
      save_results.each do |save_result|
        results << SaveResult.new(save_result)
      end
      results
    end
    
    def delete(ids, type_name)
      delete_response = @client.call(:delete, message: { :type => type_name, :ids => Array.wrap(ids) })
      delete_results = Array.wrap(delete_response.to_hash[:delete_response][:result])
      results = []
      delete_results.each do |delete_result|
        results << DeleteResult.new(delete_result)
      end
      results
    end
    
    def describe(zobject_name = "")
      result = {}
      describe_uri = URI("#{@endpoint_base}/apps/api/describe/#{zobject_name}")
      Net::HTTP.start(describe_uri.host, describe_uri.port,
          :use_ssl => describe_uri.scheme == 'https') do |http|
        describe_request = Net::HTTP::Get.new describe_uri.request_uri
        describe_request.basic_auth @username, @password
        result = Nori.new.parse(http.request(describe_request).body)
      end
      result
    end
    
    def export(export_zoql, destination_io, format = "csv", 
        zip = false, name = nil, encrypted = false, max_wait = 3600, poll_delay = 2)
      
      # Construct Export ZObject
      export_zobject = Zuora::ZObject.new
      export_zobject.format = format
      export_zobject.query = export_zoql
      export_zobject.zip = zip
      if !name.nil?
        export_zobject.name = name
      end
      export_zobject.encrypted = encrypted
      
      # Create Export record
      export_create_results = create([ export_zobject ], "Export")
      logger "********* EXPORT CREATE RESULT: #{export_create_results.inspect}"
      logger "********* #{export_create_results}"
      unless export_create_results.first.success
        raise "Error in zoql: #{export_create_results.first.errors.first.message}"
      end
      
      # Poll Zuora until CSV is ready for download
      poll_started = false
      FirePoll.poll(nil, max_wait) do
        sleep poll_delay if poll_started
        poll_started = true
        poll_zoql = "SELECT Id, FileId, Status, StatusReason FROM Export WHERE Id = '#{export_create_results.first.id}'"
        poll_zoql_result = query(poll_zoql)

        if (poll_zoql_result.size == 0) 
          result = query(export_zoql) # this should raise an error
        end
        export_zobject = poll_zoql_result.records.first
        logger "********* CURRENT EXPORT STATUS: #{export_zobject.status}"
        export_zobject.status.end_with? "ed"
      end
      
      # Check status and if complete, output file to destination IO
      logger "********* FINAL EXPORT STATUS: #{export_zobject.status}"
      case export_zobject.status
        when "Completed"
          get_file(export_zobject.file_id, destination_io)
        when "Canceled"
          raise "Error downloading file: #{export_zobject.status} - #{export_zobject.status_reason}"
        when "Failed"
          raise "Error downloading file: #{export_zobject.status} - #{export_zobject.status_reason}"
      end
      
      export_zobject
      
    ensure
      
      # Return the export ZObject even if an exception is raised
      export_zobject
    
    end
    
    def get_file(file_id, destination_io, delete_export_from_server = true)
      
      # Set IO to binary mode
      destination_io.binmode
      
      # Get file and write to IO
      file_uri = URI("#{@endpoint_base}/apps/api/file/#{file_id}")
      Net::HTTP.start(file_uri.host, file_uri.port,
          :use_ssl => file_uri.scheme == 'https') do |http|
        file_request = Net::HTTP::Get.new file_uri.request_uri
        file_request.basic_auth @username, @password
        http.request file_request do |file_response|
          file_response.read_body do |chunk|
            destination_io.write chunk
          end
        end
      end
      
      # Set pointer to beginning of file
      destination_io.rewind
      
      # Delete export from server if necessary
      if delete_export_from_server
        export_zoql = "SELECT Id FROM Export WHERE FileId = '#{file_id}'"
        export_result = query export_zoql 
        export_zobject = export_result.records.first
        delete([ export_zobject.id ], "Export")
      end

      # Return nothing
      nil
      
    end

    def login
      @client = Savon.client(endpoint: "#{@endpoint_base}/apps/services/a/#{ZUORA_API_VERSION}", 
          wsdl: File.expand_path(ZUORA_WSDL_LOCATION, __FILE__), filters: [ :password, :session, "Session" ])
      response = @client.call(:login, message: { username: @username, password: @password })
      result = LoginResult.new(response.body)
      @session = result.session
      @endpoint = result.server_url
      @client = Savon.client(endpoint: @endpoint, wsdl: File.expand_path(ZUORA_WSDL_LOCATION, __FILE__), filters: [ :password, :session ],
          soap_header: { "SessionHeader" => { :session => session }, "QueryOptions" => { :batch_size => query_batch_size } })
      result
    end
    
    def query(query_string, query_batch_size = @query_batch_size)
      response = @client.call(:query, message: { query_string: query_string } )

      logger "******* #{response}"

      QueryResult.new(response)
    end

    def query_more(query_locator, query_batch_size = @query_batch_size)
      response = @client.call(:query_more, message: { query_locator: query_locator })
      QueryResult.new(response)
    end

    def update(zobjects, type_name)
      zobjects_xml = build_zobjects_xml(zobjects, type_name)
      save_response = @client.call(:update, message: zobjects_xml)
      save_results = Array.wrap(save_response.to_hash[:update_response][:result])
      results = []
      save_results.each do |save_result|
        results << SaveResult.new(save_result)
      end
      results
    end

    private

    attr_accessor :username, :password, :session, :endpoint_base, :client
    
    def build_zobjects_xml(zobjects, type_name)
      zobjects_xml = ""
      Array.wrap(zobjects).each do |zobject|
        zobjects_xml << zobject.to_xml("api:zObjects",
            { :"xsi:type" => "obj:#{type_name}" } )
      end
      zobjects_xml
    end
    
    

    private 

    def logger(message)
      puts message if @show_logs
    end

  end

  

end