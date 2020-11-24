class DeleteIdsolicitudFromMatchRequest < ActiveRecord::Migration[5.2]
  def change
    remove_column :match_requests, :idsolicitud, :integer
  end
end
