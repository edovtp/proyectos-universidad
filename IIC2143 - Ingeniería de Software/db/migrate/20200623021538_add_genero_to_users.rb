class AddGeneroToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :genero, :string
  end
end
