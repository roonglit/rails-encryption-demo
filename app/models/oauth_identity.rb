class OauthIdentity < ApplicationRecord
  belongs_to :user

  encrypts :access_token
  encrypts :refresh_token

  validates :provider, :provider_uid, presence: true
  validates :provider_uid, uniqueness: { scope: :provider }
end
