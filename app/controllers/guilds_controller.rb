# frozen_string_literal: true

# Controls all guild behaviours
class GuildsController < ApplicationController
  before_action :authenticate_user!, except: %i[accept_invitation]

  def create
    guild = Guild.new(guild_params)

    user_already_in_a_guild and return if current_user.guild.present?
    guild_invalid(guild) and return unless guild.save

    render_message('guilds.create_success', :created)
  end

  def destroy
    guild = current_user.guild
    guild_does_not_exist and return unless guild

    guild.destroy

    render_message('guilds.destroy_success', :ok)
  end

  def invite_member
    guild = current_user.guild
    render_must_be_in_a_guild and return unless guild

    user = User.find_by(invite_params)
    raise ActiveRecord::RecordNotFound and return unless user && user&.guild_id.nil?

    guild.send_invitation_email!(user)
    render json: { message: I18n.t('guilds.invite_member_success') }, status: :created
  end

  def accept_invitation
    guild = Guild.find_signed(params[:invitation_token], purpose: :guild_invite)

    target_user = User.find_signed(params[:user_id], purpose: :find_user)
    raise ActiveRecord::RecordNotFound and return unless target_user.present?
    user_already_in_a_guild and return if target_user&.guild.present?

    target_user.update(guild_id: guild.id)
    render json: { message: I18n.t('guilds.joined_successfully') }, status: :ok
  end

  private

  def guild_params
    params.require(:guild).permit(:name, :motto)
  end

  def invite_params
    params.require(:user).permit(:email, :id)
  end

  def user_already_in_a_guild
    render json: { errors: [I18n.t('guilds.already_in_a_guild')] }, status: :unprocessable_entity
  end

  def guild_does_not_exist
    render_error('guilds.does_not_exist', :not_found)
  end

  def render_must_be_in_a_guild
    render_error('guilds.must_be_in_a_guild', :unprocessable_entity)
  end

  # TODO: Overhaul error handling to take advantage of raise Exception
  # Ideas: Standardize I18n.t exception messages | Create an ExceptionHandler class
  # that returns an array of errors as json
  def guild_invalid(guild)
    render json: { errors: guild.errors.full_messages }, status: :unprocessable_entity
  end
end
