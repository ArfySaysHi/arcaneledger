# frozen_string_literal: true

# The thing all mailers inherit - placator of rubocop
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
