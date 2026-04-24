class CreateOauthIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_identities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :provider_uid, null: false
      t.string :scopes
      t.datetime :expires_at
      t.text :access_token
      t.text :refresh_token

      t.timestamps
    end

    add_index :oauth_identities, [ :provider, :provider_uid ], unique: true
  end
end
