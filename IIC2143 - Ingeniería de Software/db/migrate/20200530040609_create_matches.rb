class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches do |t|
      t.integer :user1_id
      t.integer :user2_id
      t.boolean :cita_realizada
      t.integer :appointment_id

      t.timestamps
    end
  end
end
