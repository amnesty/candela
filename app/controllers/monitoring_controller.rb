class MonitoringController < ApplicationController
  
  def index
    if params[:performance]
      performance = current_agent.performances.find(params[:performance])
      unless performance
        redirect_to monitoring_path, :alert => "Performance not found"
      else
        render :partial => 'following_performance', :object => performance
        return
      end
    end
  end
end
