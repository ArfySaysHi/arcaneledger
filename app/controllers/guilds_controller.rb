# frozen_string_literal: true

# Controls all guild behaviours
class GuildsController < ApplicationController
  before_action :authenticate_user!

  def create
    guild = Guild.new(guild_params)

    user_already_in_a_guild and return if current_user.guild.present?
    guild_invalid(guild) and return unless guild.save

    render json: { message: I18n.t('guilds.create_success') }, status: :created
  end

  def destroy
    guild = current_user.guild
    guild_does_not_exist and return unless guild

    guild.destroy

    render json: { message: I18n.t('guilds.destroy_success') }, status: :ok
  end

  private

  def guild_params
    params.require(:guild).permit(:name, :motto)
  end

  def user_already_in_a_guild
    render json: { errors: [I18n.t('guilds.already_in_a_guild')] }, status: :unprocessable_entity
  end

  def guild_does_not_exist
    render json: { errors: [I18n.t('guilds.does_not_exist')] }, status: :not_found
  end

  def guild_invalid(guild)
    render json: { errors: guild.errors.full_messages }, status: :unprocessable_entity
  end
end
