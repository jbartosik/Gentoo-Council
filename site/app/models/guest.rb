class Guest < Hobo::Model::Guest

  def administrator?
    false
  end

  def council_member?
    false
  end

end
