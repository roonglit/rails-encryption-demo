class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]


  def self.from_omniauth(access_token)
    data = access_token.info
    User.where(email: data["email"]).first_or_create do |user|
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
