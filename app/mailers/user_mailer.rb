class UserMailer < ActionMailer::Base
  default from: "michaelmuse@gmail.com"

  def index
    @user = current_user
  end
end
