class RemoveSubdomainFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :subdomain
  end
end
