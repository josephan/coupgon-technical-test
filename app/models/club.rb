class Club < ApplicationRecord
  has_many :valid_tees, dependent: :destroy
  has_many :invalid_tees, dependent: :destroy

  validates :name, uniqueness: {case_sensitive: false}, presence: true

  def next_available_time(start_time, end_time)
  end
end
