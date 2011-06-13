class Proxy < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    # Remeber nicks from when meeting took place
    # May be useful when reading logs (if user changes nick)
    council_member_nick :string, :null => false
    proxy_nick          :string, :null => false
    timestamps
  end

  belongs_to :council_member, :class_name => 'User', :null => false
  belongs_to :proxy, :class_name => 'User', :null => false
  belongs_to :agenda, :null => false

  validates_presence_of :council_member, :proxy, :agenda
  validates_uniqueness_of :council_member_id, :scope => :agenda_id
  validates_uniqueness_of :proxy_id, :scope => :agenda_id
  validate :council_member_must_be_council_member
  validate :proxy_must_not_be_council_member

  # --- Permissions --- #

  def create_permitted?
    return false unless acting_user.council_member?
    council_member_is?(acting_user)
  end

  def update_permitted?
    false
  end

  def destroy_permitted?
    return false if agenda.state == 'old'
    council_member_is?(acting_user)
  end

  def view_permitted?(field)
    true
  end

  before_create do |proxy|
    proxy.council_member_nick = proxy.council_member.irc_nick
    proxy.proxy_nick          = proxy.proxy.irc_nick
  end

  protected
    def council_member_must_be_council_member
      return if council_member.nil?
      errors.add(:council_member, 'must be council member') unless council_member.council_member?
    end
    def proxy_must_not_be_council_member
      return if proxy.nil?
      errors.add(:proxy, 'must not be council member') if proxy.council_member?
    end
end
