class Menu < ApplicationRecord
  validates :nombre, :descripcion, :precio, presence: true
  belongs_to :local
end
