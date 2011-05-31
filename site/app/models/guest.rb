class Guest < Hobo::Model::Guest

  def administrator?
    false
  end

  def council_member?
    false
  end

  def can_appoint_a_proxy?
    false
  end
end
