# frozen_string_literal: true

module Guilds
  # Handles all invitation logic for guilds
  class InvitationsController < ApplicationController
    before_action :authenticate_user!, except: %i[show]

    rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :invalid_token

    def show
      guild = Guild.find_signed!(params[:invitation_token], purpose: :guild_invite)
      target_user = User.find_signed!(params[:user_id], purpose: :find_user)
      user_guilded and return if target_user.guilded?

      target_user.update(guild_id: guild.id)
      render json: { message: I18n.t('guilds.joined_successfully') }, status: :ok
    end

    def create
      guild = current_user.guild
      render_must_be_in_a_guild and return unless guild

      user = User.where(guild_id: nil).find_by!(invite_params)

      guild.send_invitation_email!(user)
      render json: { message: I18n.t('guilds.invite_member_success') }, status: :created
    end

    private

    def invite_params
      params.expect(user: %i[email id])
    end

    def invalid_token
      render_error(:invalid_token, status: :unprocessable_entity)
    end

    def user_guilded
      render_error('guilds.already_in_a_guild', status: :unprocessable_entity)
    end
  end
end
