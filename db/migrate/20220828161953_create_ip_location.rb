class CreateIpLocation < ActiveRecord::Migration[7.0]
  def change
    create_table :ip_locations, id: false do |t|
      t.inet :ip_address, unique: true, null: false, index: true, primary_key: true
      t.string :country_code, null: false
      t.string :country, null: false
      t.string :city, null: false
      t.decimal :latitude, null: false
      t.decimal :longitude, null: false
      t.bigint :mystery_value, null: false

      t.timestamps
    end
  end
end
