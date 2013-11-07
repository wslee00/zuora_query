require 'zuora'
require 'csv'

class QueryToolController < ApplicationController
  def index
    @connectors = Connector.all
    @connector_id = params[:connector_id] || @connectors.first.id

    @current_connector = Connector.find(@connector_id)
  end

  def query

    begin 
      connector = Connector.find(params[:connector_id])
      connection = get_connection(connector)

      save_state(connector)
      connector.reload

      @user_query = get_user_query

    	file = Tempfile.new("user_query")
	    connection.export(@user_query, file)

      @header_row = nil
      @data_rows = []
      @results = { header: @header_row, data: @data_rows }
      CSV.foreach(file.path, headers: true, return_headers: true ) do |data|
        if data.header_row? 
          @header_row = data.to_hash
        else
          @data_rows.push(data.to_hash)
        end
      end

      save_query_results(connector)
      @query_results = connector.query_results.order("created_at DESC").limit(5)

      respond_to do |format|
        format.html { render action: 'view' }
        format.js { render layout: false }
        format.json { render json: @results, status: :success }
      end
    rescue => e
      flash[:error] = e.message
      @error_message = e.message + "\n" + e.backtrace.inspect
    end
  end

  private 

  def get_connection(connector)
    connector or raise "Connector not specified"

    return Zuora::Client.new(connector.username, connector.password, 
      "https://#{connector.url}")
  end

  def save_state(connector)
    connector.update_attributes(editor_state: params[:query_editor],
      num_limit: params[:num_limit],
      order_by_field: params[:order_by_field],
      order_by_direction: params[:order_by_direction])
    QueryToolState.first.update_attributes(last_connector_id: params[:connector_id])
  end

  def get_user_query
    user_query = params[:selected_query].blank? ? params[:query_editor] : params[:selected_query]


    unless user_query.index(/(\s|^)limit\s/i)

      unless params[:order_by_field].blank?
        unless user_query.downcase.include? "order by"
          user_query += " order by #{params[:order_by_field]} #{params[:order_by_direction]}"
        end
      end

      user_query += " limit #{params[:num_limit]}"
    end

    user_query
  end

  def save_query_results(connector)
    connector.query_results.create(query: @user_query, 
      header_row: @header_row, data_rows: @data_rows)

    if connector.query_results.size > 100
      connector.query_results.order(:created_at).limit(1).destroy
    end
  end

end
