class Comment < ApplicationRecord
  validates :contenido, presence: true
  belongs_to :local
  belongs_to :user
end
