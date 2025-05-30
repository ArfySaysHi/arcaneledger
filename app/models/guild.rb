# frozen_string_literal: true

# A company
class Guild < ApplicationRecord
  INVITATION_TOKEN_EXPIRATION = 10.minutes

  has_many :users, dependent: :nullify
  has_one :inventory, as: :storable, dependent: :destroy
  has_many :accounts, dependent: :destroy

  after_create :create_inventory!

  validates :name, uniqueness: true, presence: true
  validates :motto, presence: true

  def generate_invitation_token
    signed_id(expires_in: INVITATION_TOKEN_EXPIRATION, purpose: :guild_invite)
  end

  def send_invitation_email!(user)
    invitation_token = generate_invitation_token
    GuildMailer.invitation(user, invitation_token).deliver_now
  end
end
