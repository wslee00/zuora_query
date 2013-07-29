require 'zuora'
require 'csv'

class QueryToolController < ApplicationController
  def view
  end

  def query
  	@user_query = params[:query]
  	@user_query = "select id from account limit 1" if @user_query.blank?
  	@zuora_client = Zuora::Client.new('william.lee@tripadvisor.com',
        'thr1ll3rZ',
        'https://apisandbox.zuora.com')

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
