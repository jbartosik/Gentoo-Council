namespace :management do
  desc 'Update discussion times for agenda items that are not assigned or assigned to current agenda'
  task :update_discussion_times => :environment do
    current_items = Agenda.current.agenda_items
    unassigned_items = AgendaItem.agenda_is(nil)
    all_items = current_items + unassigned_items
    all_items.each { |item| item.update_discussion_time }
  end
end
