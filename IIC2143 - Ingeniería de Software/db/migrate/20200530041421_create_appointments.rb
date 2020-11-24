class CreateAppointments < ActiveRecord::Migration[5.2]
  def change
    create_table :appointments do |t|
      t.integer :match_id
      t.integer :solicitante_id
      t.integer :local_id
      t.date :fecha

      t.timestamps
    end
  end
end
