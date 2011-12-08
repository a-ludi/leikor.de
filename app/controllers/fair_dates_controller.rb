class FairDatesController < ApplicationController
  def index
    @fair_dates = FairDate.find :all, :order => "from_date ASC, to_date ASC"
    @stylesheets = ['static', 'fair_dates/index']
    @title = 'Messetermine'
  end
end
