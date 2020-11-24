class Appointment < ApplicationRecord
  validates :local_id, :fecha, presence: true

  belongs_to :match
end
