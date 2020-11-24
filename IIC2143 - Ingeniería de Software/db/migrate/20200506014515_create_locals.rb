class CreateLocals < ActiveRecord::Migration[5.2]
  def change
    create_table :locals do |t|
      t.string :nombre
      t.string :descripcion
      t.boolean :aceptado, default: false
      t.integer :idusuario
      t.integer :idcomuna

      t.timestamps
    end
  end
end
