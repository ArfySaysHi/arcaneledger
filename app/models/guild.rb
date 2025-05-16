# frozen_string_literal: true

# A company that is controlled by a council
class Guild < ApplicationRecord
  validates :name, uniqueness: true, presence: true
  validates :motto, presence: true
end
