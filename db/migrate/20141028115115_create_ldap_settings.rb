class CreateLdapSettings < ActiveRecord::Migration
  def change
    create_table :ldap_settings do |t|
      t.integer :default_gid_number
      t.integer :next_uid_number
      t.timestamps
    end
  end
end
