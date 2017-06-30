class User < ApplicationRecord
  has_many :valid_tees, dependent: :destroy
  has_many :invalid_tees, dependent: :destroy

  validates :email, uniqueness: {case_sensitive: false}, presence: true
end
