require 'spec_helper'

describe Notification::VenueInfo do
  it "has a valid factory" do
    FactoryGirl.create(:notification_venue_info).should be_valid
  end
  
  it "is generated by cron if time_start is less than 24 hours and more than 23 hours" do
    venue = FactoryGirl.create(:venue, :start_time => Time.now + 23.4.hours)
    #Venue.one_day_ahead.should_not be_empty
    Venue.notify_next_day.should be_true
  end
  
  it "is generated by cron if time_start is less than 2 hour and more than 60 minutes" do
    venue = FactoryGirl.create(:venue, :start_time => Time.now + 70.minutes)
    #Venue.one_hour_ahead.should_not be_empty
    Venue.notify_next_2_hour.should be_true
  end
end
