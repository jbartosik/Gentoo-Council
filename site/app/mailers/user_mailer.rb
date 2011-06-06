class UserMailer < ActionMailer::Base
  default :from => "no-reply@#{host}"

  def forgot_password(user, key)
    @user, @key = user, key
    mail( :subject => "#{app_name} -- forgotten password",
          :to      => user.email )
  end

  def meeting_reminder(user, agenda)
    @user = user
    @agenda = agenda
    mail(:subject => "Upcoming meeting reminder - #{agenda.meeting_time.to_s}",
          :to => user.email)
  end
end
