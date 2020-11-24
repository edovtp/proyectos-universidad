class AddLuckyIdToValuations < ActiveRecord::Migration[5.2]
  def change
    add_column :valuations, :lucky_id, :integer
  end
end
