require 'zuora'
require 'csv'

class QueryToolController < ApplicationController
  def index
    render 'view'
  end

  def query
    @username = params[:username].blank? ? 'william.lee@tripadvisor.com' : params[:username]
    @password = params[:password].blank? ? 'thr1ll3rZ' : params[:password]
    @zuora_url = params[:zuora_url].blank? ? 'apisandbox.zuora.com' : params[:zuora_url]

  	@user_query = params[:selected_query]

  	@user_query = "select id from account limit 1" if @user_query.blank?
  	@zuora_client = Zuora::Client.new(@username,
        @password, "https://#{@zuora_url}")

  	file = Tempfile.new("user_query")
  	begin
	    @zuora_client.export(@user_query, file)
	  rescue => e
	  	flash[:error] = e.message
	  end

    @header_row = nil
    @data_rows = []
    @results = { header: @header_row, data: @data_rows }
    CSV.foreach(file.path, headers: true, return_headers: true ) do |data|
      if data.header_row? 
        @header_row = data
      else
        @data_rows.push(data)
      end
    end

    respond_to do |format|
      format.html { render action: 'view' }
      format.js { render layout: false }
      format.json { render json: @results, status: :success }
    end
  end
end
