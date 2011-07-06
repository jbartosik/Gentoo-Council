require 'spec_helper'

describe 'suggested_meeting_times' do
  it 'should return proper arrays for sample configs' do
    CustomConfig['Doodle']['min_days_between_meetings'] = 0
    CustomConfig['Doodle']['days_for_meeting'] = 1
    times = suggested_meeting_times
    times.length.should be_equal(25)
    times.first.should == 0.days.from_now.strftime('%Y.%m.%d %H:00')
    times.last.should == 1.day.from_now.strftime('%Y.%m.%d %H:00')

    CustomConfig['Doodle']['min_days_between_meetings'] = 1
    CustomConfig['Doodle']['days_for_meeting'] = 2
    times = suggested_meeting_times
    times.length.should be_equal(49)
    times.first.should == 1.days.from_now.strftime('%Y.%m.%d %H:00')
    times.last.should == 3.days.from_now.strftime('%Y.%m.%d %H:00')
  end
end


describe 'new_poll_for_council_meeting' do
  it 'should return proper link' do
    new_poll_response = Net::HTTPCreated.new 'a', 'a', 'a'
    new_poll_response.header['content-location'] = 'poll_id'
    CustomConfig['Doodle']['min_days_between_meetings'] = 1
    CustomConfig['Doodle']['days_for_meeting'] = 2
    CustomConfig['Doodle']['doodle_host'] = 'example.com'
    CustomConfig['Doodle']['doodle_api'] = 'api'

    Net::HTTP.should_receive(:start).and_return(new_poll_response)
    new_poll_for_council_meeting.should == 'http://example.com/polls/poll_id'
  end
end
