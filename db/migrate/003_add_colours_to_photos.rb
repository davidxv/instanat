class AddColoursToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.string :colours
    end
  end

  def self.down
    change_table :photos do |t|
      t.string :colours
    end
  end
end
