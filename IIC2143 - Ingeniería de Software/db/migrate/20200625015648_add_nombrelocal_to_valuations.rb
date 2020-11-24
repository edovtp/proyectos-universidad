class AddNombrelocalToValuations < ActiveRecord::Migration[5.2]
  def change
    add_column :valuations, :local_name, :string
  end
end
