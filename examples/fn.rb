#!/usr/bin/env ruby
#
require 'fnordmetric'

FnordMetric.namespace :example do

# 
#   numeric (delta) gauge, 1-day tick
gauge :icecreams_eaten_per_day, :tick => 1.day.to_i, :title => "Daily icecreams"
gauge :icecreams_eaten_per_hour, :tick => 1.hour.to_i, :title => "Hourly icecreams"
gauge :icecreams_eaten_per_minute, :tick => 1.minute.to_i, :title => "Hourly icecreams"

gauge :strawberry_icecreams_eaten_per_day, :tick => 1.day.to_i, :title => "Daily strawberry icecreams"

event(:icecream) do
  incr :icecreams_eaten_per_day
  incr :icecreams_eaten_per_hour
  incr :icecreams_eaten_per_minute
  incr :strawberry_icecreams_eaten_per_day if data[:flavor] = 'strawberry'
end

# Performance
gauge :delivery_performance_per_minute, :tick => 1.minute.to_i, :average => true, :progressive => true, :title => "Delivery performance per minute"
gauge :delivery_performance_per_hour, :tick => 1.hour.to_i, :average => true, :progressive => true, :title => "Delivery performance per hour"

event(:delivery_performance) do
  puts "got #{data[:time]} for method #{data[:method]}"
  incr :delivery_performance_per_hour, data[:time] if data[:method] == 'MainController#deliver'
  incr :delivery_performance_per_minute, data[:time] if data[:method] == 'MainController#deliver'
end

# All events
#   numeric (progressive) gauge, 1-day tick
gauge :events_total, :tick => 1.day.to_i, :progressive => true, :title => "Daily Events (total)"

# on _every_ event
event :"*" do
  incr :events_total 
end

# Unique pageviews
#   numeric (delta) gauge, increments uniquely by session_key
gauge :pageviews_daily_unique, :tick => 1.day.to_i, :unique => true, :title => "Unique Visits (Daily)"

#   three-dimensional (delta) gauge (time->key->value)
gauge :pageviews_per_url_daily, :tick => 1.day.to_i, :title => "Daily Pageviews per URL", :three_dimensional => true

event :_pageview do
  # increment the daily_uniques gauge by 1 if session_key hasn't been seen
  # in this tick yet
  incr :pageviews_daily_unique
  # increment the pageviews_per_url_daily gauge by 1 where key = 'page2'
  incr_field :pageviews_per_url_daily, data[:url]
end

#
# WIDGETS
#

widget 'Overview', {
  :title => "Icecream per day",
  :type => :timeline,
  :plot_style => :areaspline,
  :gauges => :icecreams_eaten_per_day,
  :include_current => true,
  :autoupdate => 10
}

widget 'Overview', {
  :title => "Icecream per hour",
  :type => :timeline,
  :plot_style => :areaspline,
  :gauges => :icecreams_eaten_per_hour,
  :include_current => true,
  :autoupdate => 10
}

widget 'Overview', {
  :title => "Icecream per minute",
  :type => :timeline,
  :plot_style => :areaspline,
  :gauges => :icecreams_eaten_per_minute,
  :include_current => true,
  :autoupdate => 10
}

widget 'Pages', {
  :title => "Top Pages",
  :type => :toplist,
  :autoupdate => 20,
  :include_current => true,
  :gauges => [ :pageviews_per_url_daily ]
}

widget 'Performance', {
  :title => "Delivery performance metrics per hour",
  :type => :timeline,
  :plot_style => :areaspline,
  :gauges =>  :delivery_performance_per_hour,
  :include_current => true,
  :autoupdate => 2
}

widget 'Performance', {
  :title => "Delivery performance metrics per minute",
  :type => :timeline,
  :plot_style => :areaspline,
  :gauges =>  :delivery_performance_per_minute,
  :include_current => true,
  :autoupdate => 2
}



end

FnordMetric.standalone

