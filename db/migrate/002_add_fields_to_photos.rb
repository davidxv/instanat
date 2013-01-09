class AddFieldsToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.datetime :media_url_expires_at
    end
  end

  def self.down
    change_table :photos do |t|
      t.remove :media_url_expires_at
    end
  end
end
