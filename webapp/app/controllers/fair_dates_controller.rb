class FairDatesController < ApplicationController
  def index
    @fair_dates = FairDate.find :all, :order => "'from' ASC, 'to' ASC"
    @stylesheets = ['static', 'fair_dates/index']
    @title = 'Messetermine'
  end
end
