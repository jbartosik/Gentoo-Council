def suggested_meeting_times
  meeting_time = CustomConfig['Doodle']['min_days_between_meetings'].days.from_now
  meeting_days = CustomConfig['Doodle']['days_for_meeting']

  options = (0..(meeting_days*24)).collect do |hours_later|
    (meeting_time + hours_later.hours).strftime '%Y.%m.%d %H:00'
  end
end

def doodle_new_pool_xml
    namespace = OpenStruct.new(:options => suggested_meeting_times)

    doodle_new_pool_erb_path = "#{::Rails.root.to_s}/app/views/agendas/doodle_create.erb"
    doodle_new_pool_erb_file = File.open(doodle_new_pool_erb_path)
    doodle_new_pool_erb_raw = doodle_new_pool_erb_file.read
    doodle_new_pool_erb_parsed = ERB.new(doodle_new_pool_erb_raw)

    doodle_new_pool_erb_parsed.result(namespace.send(:binding))
end

def new_poll_for_council_meeting
   resource = "/#{CustomConfig['Doodle']['doodle_api']}/polls"
   headers = {'content-type' => 'application/xml'}

    a = Net::HTTP.start(CustomConfig['Doodle']['doodle_host']) do |http|
      http.post(resource, doodle_new_pool_xml, headers)
    end

    poll_id = a.header['content-location']
     "http://#{CustomConfig['Doodle']['doodle_host']}/polls/#{poll_id}"
end
