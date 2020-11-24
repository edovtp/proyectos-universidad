class CreateMatchRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :match_requests do |t|
      t.integer :idsolicitud
      t.integer :solicitado
      t.integer :solicitante

      t.timestamps
    end
  end
end
