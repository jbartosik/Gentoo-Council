class VotingOptionsController < ApplicationController

  hobo_model_controller

  auto_actions :all

  def community_vote
    option = VotingOption.find(params[:id])
    if option.nil?
      flash[:notice] = "No such voting option"
      redirect_to :controller => :agendas, :action => :index
    else
      if current_user.signed_up?
        Vote.vote_for_option(current_user, option, false)
        flash[:notice] = "You voted for #{option.description}"
      else
        flash[:notice] = "You must be logged in to vote"
      end
      redirect_to :controller => :agenda_items, :action => :show, :id => option.agenda_item_id
    end
  end
end
