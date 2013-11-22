class ConnectorsController < ApplicationController
  def new
    @connector = Connector.new(connector_type: "Zuora", url: "http://apisandbox.zuora.com")
    @url_values = ['apisandbox.zuora.com','www.zuora.com']
  end

  def create
    @connector = Connector.new(params[:connector])
    if @connector.save
      redirect_to connectors_path
    else
      render "new"
    end
  end

  def update
    @connector = Connector.find(params[:id])
    if @connector.update_attributes(params[:connector])
      redirect_to connectors_path
    else
      render "edit"
    end
  end

  def edit
    @connector = Connector.find(params[:id])
    @url_values = ['apisandbox.zuora.com','www.zuora.com']
  end

  def show
    @connector = Connector.find(params[:id])
  end

  def destroy
    Connector.find(params[:id]).delete
    redirect_to connectors_path
  end


  def index
    @connectors = Connector.all
  end
end
