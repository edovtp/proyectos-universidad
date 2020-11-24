class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :matches, :appointment_id, :local_id
  end
end
