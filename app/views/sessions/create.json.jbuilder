# frozen_string_literal: true

json.message @message
json.user do
  json.id         @data.id
  json.email      @data.email
  json.created_at @data.created_at
end
