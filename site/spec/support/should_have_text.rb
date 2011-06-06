module Mail
  class Message
    # emailspec doesn't add this, so we have to
    def has_text?(text)
      not body.to_s.match(text).nil?
    end
  end
end
