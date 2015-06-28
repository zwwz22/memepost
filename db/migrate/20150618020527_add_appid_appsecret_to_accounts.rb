class AddAppidAppsecretToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :app_id, :string
    add_column :accounts, :app_secret, :string
  end
end
