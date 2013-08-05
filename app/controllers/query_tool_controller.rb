require 'zuora'
require 'csv'

class QueryToolController < ApplicationController
  def view
  end

  def query
    @username = params[:username].blank? ? 'william.lee@tripadvisor.com' : params[:username]
    @password = params[:password].blank? ? 'thr1ll3rZ' : params[:password]
    @zuora_url = params[:zuora_url].blank? ? 'apisandbox.zuora.com' : params[:zuora_url]

  	@user_query = params[:query]
  	@user_query = "select id from account limit 1" if @user_query.blank?
  	@zuora_client = Zuora::Client.new(@username,
        @password, "https://#{@zuora_url}")

  	file = Tempfile.new("user_query")
  	begin
	    @zuora_client.export(@user_query, file)
	  rescue => e
	  	flash[:error] = e.message
	  end

    @result_path = file.path

    render 'query_tool/view'
  end
end
