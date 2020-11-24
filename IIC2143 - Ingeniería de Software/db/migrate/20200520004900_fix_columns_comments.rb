class FixColumnsComments < ActiveRecord::Migration[5.2]
  def change
    rename_column :comments, :idusuario, :user_id
    rename_column :comments, :idlocal, :local_id
  end
end
