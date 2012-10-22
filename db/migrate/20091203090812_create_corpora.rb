class CreateCorpora < ActiveRecord::Migration
  def change
    create_table :corpora do |t|
      t.string :name, :null => false
      t.integer :default_max_hits  # it might be a good idea to set this if the corpus is very big

      t.timestamps
    end
  end
end
