class HomeController < ApplicationController
  def index
    analytical.track_pageview
  end
  
  def event
    analytical.event('test_event', { :some => 'data' })
    render :index
  end
end
