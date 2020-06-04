class CreateStocksTable < ActiveRecord::Migration[5.2]
    def change
      create_table :stocks do |t|
        t.string :ticker
        t.integer :quantity
        t.decimal :total
        t.integer :user_id
      end
    end
  end