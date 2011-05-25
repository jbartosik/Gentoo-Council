# If there are no active agendas create one
begin
  return unless ['development', 'production'].include? Rails.env
  return if Agenda.state_is_not(:old).count > 0
  Agenda.create!
rescue
  # Just ignore it. It will happen when:
  #  * Everything is fine, but database is missing (eg. rake db:schema:load)
  #    * It's safe to ignore this then
  #  * Something is seriously wrong (like broken db)
  #    * Users will notice this anyway
end
