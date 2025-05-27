# frozen_string_literal: true

# Controls all guild behaviours
class GuildsController < ApplicationController
  before_action :authenticate_user!

  def create
    guild = Guild.new(guild_params)
    user_already_in_a_guild and return if current_user.guild.present?

    guild.save!
    render_message!(:create_success, status: :created)
  end

  def destroy
    guild = current_user.guild
    guild_does_not_exist and return unless guild

    guild.destroy!
    render_message!(:destroy_success)
  end

  private

  def guild_params
    params.expect(guild: %i[name motto])
  end

  def user_already_in_a_guild
    render_error!(:already_in_a_guild, status: :unprocessable_entity)
  end

  def guild_does_not_exist
    render_error!(:does_not_exist, status: :not_found)
  end
end
