class ChangeColumnMatchrequest < ActiveRecord::Migration[5.2]
  def change
    rename_column :match_requests, :solicitante, :solicitante_id
    rename_column :match_requests, :solicitado, :solicitado_id
  end
end
