class CreateValuations < ActiveRecord::Migration[5.2]
  def change
    create_table :valuations do |t|
      t.integer :puntuacion, default: 0
      t.integer :user_id
      t.integer :local_id
      t.boolean :realizada, default: false

      t.timestamps
    end
  end
end
