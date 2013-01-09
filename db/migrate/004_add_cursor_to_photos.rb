class AddCursorToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.string :cursor
    end
  end

  def self.down
    change_table :photos do |t|
      t.remove :cursor
    end
  end
end
