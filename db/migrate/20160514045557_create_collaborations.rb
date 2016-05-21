class CreateCollaborations < ActiveRecord::Migration
  def change
     create_table :collaborations do |t|
       t.integer :wiki_id, index: true
       t.integer :user_id, index: true
       t.timestamps
     end

   end
end
