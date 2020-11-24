class FixColumnasLocal < ActiveRecord::Migration[5.2]
  def change
    rename_column :locals, :idusuario, :user_id
    rename_column :locals, :idcomuna, :commune_id
  end
end

