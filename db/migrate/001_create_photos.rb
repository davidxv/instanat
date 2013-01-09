class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :path
      t.datetime :modified_at
      t.string :media_url
      t.datetime :media_url_fetched_at
      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
