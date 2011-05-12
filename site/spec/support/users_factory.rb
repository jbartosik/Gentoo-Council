def users_factory(*roles)
  roles.flatten!
  r = []
  for role in roles
    case role
      when :guest
        r.push Guest.new
      when :user
        r.push Factory(:user)
      when :council
        r.push Factory(:user, :council_member => true)
      when :admin
        r.push Factory(:user, :administrator => true)
      when :council_admin
        r.push Factory(:user, :council_member => true, :administrator => true)
    end
  end
  (r.count < 2) ? r.first : r
end

AllRoles = [:guest, :user, :council, :admin, :council_admin]
