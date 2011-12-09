class FairDatesController < ApplicationController
  def index
    @fair_dates = FairDate.find :all, :order => "from_date ASC, to_date ASC"
    @stylesheets = ['static', 'fair_dates/index']
    @title = 'Messetermine'
  end
  
  def edit
    @fair_date = FairDate.find params[:id]
    @stylesheets = ['message']
    @title = 'Messetermin bearbeiten'
  end
end
