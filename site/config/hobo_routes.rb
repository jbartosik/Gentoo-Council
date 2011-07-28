# This is an auto-generated file: don't edit!
# You can add your own routes in the config/routes.rb file
# which will override the routes in this file.

Council::Application.routes.draw do


  # Resource routes for controller "proxies"
  get 'proxies(.:format)' => 'proxies#index', :as => 'proxies'
  get 'proxies/new(.:format)', :as => 'new_proxy'
  get 'proxies/:id/edit(.:format)' => 'proxies#edit', :as => 'edit_proxy'
  get 'proxies/:id(.:format)' => 'proxies#show', :as => 'proxy', :constraints => { :id => %r([^/.?]+) }
  post 'proxies(.:format)' => 'proxies#create', :as => 'create_proxy'
  put 'proxies/:id(.:format)' => 'proxies#update', :as => 'update_proxy', :constraints => { :id => %r([^/.?]+) }
  delete 'proxies/:id(.:format)' => 'proxies#destroy', :as => 'destroy_proxy', :constraints => { :id => %r([^/.?]+) }


  # Lifecycle routes for controller "users"
  post 'users/signup(.:format)' => 'users#do_signup', :as => 'do_user_signup'
  get 'users/signup(.:format)' => 'users#signup', :as => 'user_signup'
  put 'users/:id/reset_password(.:format)' => 'users#do_reset_password', :as => 'do_user_reset_password'
  get 'users/:id/reset_password(.:format)' => 'users#reset_password', :as => 'user_reset_password'

  # Resource routes for controller "users"
  get 'users/:id/edit(.:format)' => 'users#edit', :as => 'edit_user'
  get 'users/:id(.:format)' => 'users#show', :as => 'user', :constraints => { :id => %r([^/.?]+) }
  put 'users/:id(.:format)' => 'users#update', :as => 'update_user', :constraints => { :id => %r([^/.?]+) }
  delete 'users/:id(.:format)' => 'users#destroy', :as => 'destroy_user', :constraints => { :id => %r([^/.?]+) }

  # Show action routes for controller "users"
  get 'users/:id/account(.:format)' => 'users#account', :as => 'user_account'

  # User routes for controller "users"
  match 'login(.:format)' => 'users#login', :as => 'user_login'
  get 'logout(.:format)' => 'users#logout', :as => 'user_logout'
  match 'forgot_password(.:format)' => 'users#forgot_password', :as => 'user_forgot_password'


  # Lifecycle routes for controller "agendas"
  put 'agendas/:id/close(.:format)' => 'agendas#do_close', :as => 'do_agenda_close'
  get 'agendas/:id/close(.:format)' => 'agendas#close', :as => 'agenda_close'
  put 'agendas/:id/reopen(.:format)' => 'agendas#do_reopen', :as => 'do_agenda_reopen'
  get 'agendas/:id/reopen(.:format)' => 'agendas#reopen', :as => 'agenda_reopen'
  put 'agendas/:id/archive(.:format)' => 'agendas#do_archive', :as => 'do_agenda_archive'
  get 'agendas/:id/archive(.:format)' => 'agendas#archive', :as => 'agenda_archive'

  # Resource routes for controller "agendas"
  get 'agendas(.:format)' => 'agendas#index', :as => 'agendas'
  get 'agendas/new(.:format)', :as => 'new_agenda'
  get 'agendas/:id/edit(.:format)' => 'agendas#edit', :as => 'edit_agenda'
  get 'agendas/:id(.:format)' => 'agendas#show', :as => 'agenda', :constraints => { :id => %r([^/.?]+) }
  post 'agendas(.:format)' => 'agendas#create', :as => 'create_agenda'
  put 'agendas/:id(.:format)' => 'agendas#update', :as => 'update_agenda', :constraints => { :id => %r([^/.?]+) }
  delete 'agendas/:id(.:format)' => 'agendas#destroy', :as => 'destroy_agenda', :constraints => { :id => %r([^/.?]+) }


  # Resource routes for controller "agenda_items"
  get 'agenda_items/new(.:format)', :as => 'new_agenda_item'
  get 'agenda_items/:id/edit(.:format)' => 'agenda_items#edit', :as => 'edit_agenda_item'
  get 'agenda_items/:id(.:format)' => 'agenda_items#show', :as => 'agenda_item', :constraints => { :id => %r([^/.?]+) }
  post 'agenda_items(.:format)' => 'agenda_items#create', :as => 'create_agenda_item'
  put 'agenda_items/:id(.:format)' => 'agenda_items#update', :as => 'update_agenda_item', :constraints => { :id => %r([^/.?]+) }
  delete 'agenda_items/:id(.:format)' => 'agenda_items#destroy', :as => 'destroy_agenda_item', :constraints => { :id => %r([^/.?]+) }


  # Resource routes for controller "voting_options"
  get 'voting_options(.:format)' => 'voting_options#index', :as => 'voting_options'
  get 'voting_options/new(.:format)', :as => 'new_voting_option'
  get 'voting_options/:id/edit(.:format)' => 'voting_options#edit', :as => 'edit_voting_option'
  get 'voting_options/:id(.:format)' => 'voting_options#show', :as => 'voting_option', :constraints => { :id => %r([^/.?]+) }
  post 'voting_options(.:format)' => 'voting_options#create', :as => 'create_voting_option'
  put 'voting_options/:id(.:format)' => 'voting_options#update', :as => 'update_voting_option', :constraints => { :id => %r([^/.?]+) }
  delete 'voting_options/:id(.:format)' => 'voting_options#destroy', :as => 'destroy_voting_option', :constraints => { :id => %r([^/.?]+) }

end
