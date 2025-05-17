# frozen_string_literal: true

# A company
class Guild < ApplicationRecord
  has_many :users, dependent: :nullify

  validates :name, uniqueness: true, presence: true
  validates :motto, presence: true
end
