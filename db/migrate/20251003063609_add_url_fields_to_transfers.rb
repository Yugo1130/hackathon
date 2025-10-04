class AddUrlFieldsToTransfers < ActiveRecord::Migration[8.0]
  def change
    add_column :transfers, :slug, :string

    add_index :transfers, :slug, unique: true
  end
end
