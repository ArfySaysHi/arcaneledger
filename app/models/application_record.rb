# frozen_string_literal: true

# All ActiveRecords inherit from this - placate rubocop
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
