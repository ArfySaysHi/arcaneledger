# frozen_string_literal: true

# Handles guild invitations
class GuildMailer < ApplicationMailer
  def invitation(user, invitation_token)
    @user = user
    @user_id = user.generate_find_user_token
    @invitation_token = invitation_token

    mail to: user.confirmable_email, subject: I18n.t('guilds.subject_invite')
  end
end
