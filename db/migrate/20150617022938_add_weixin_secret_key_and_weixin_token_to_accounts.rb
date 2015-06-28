class AddWeixinSecretKeyAndWeixinTokenToAccounts < ActiveRecord::Migration
  def self.up
    create_table(:accounts) do |t|
      t.string :name
      t.string :image_url
      t.string :weixin_secret_key
      t.string :weixin_token
    end
    add_index :accounts, :weixin_secret_key
    add_index :accounts, :weixin_token
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
