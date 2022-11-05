class CreateReletionships < ActiveRecord::Migration[6.1]
  def change
    create_table :reletionships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
  end
end
