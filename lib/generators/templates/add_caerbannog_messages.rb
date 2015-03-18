class AddCaerbannogMessages < ActiveRecord::Migration
  def change
    create_table :caerbannog_messages do |t|
      t.string :name, :null => false
      t.text :payload 
      t.timestamp :created_at
    end
  end
end

