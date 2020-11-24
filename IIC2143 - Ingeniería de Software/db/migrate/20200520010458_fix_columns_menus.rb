class FixColumnsMenus < ActiveRecord::Migration[5.2]
  def change
    rename_column :menus, :idlocal, :local_id
  end
end
