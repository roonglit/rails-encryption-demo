class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]

    identity = OauthIdentity.find_or_initialize_by(
      provider: "google",
      provider_uid: auth.uid
    )
    identity.user ||= User.where(email: auth.info.email).first_or_create do |user|
      user.password = Devise.friendly_token[0, 20]
    end
    identity.assign_attributes(
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      scopes: auth.credentials.scope,
      expires_at: (Time.at(auth.credentials.expires_at) if auth.credentials.expires_at)
    )

    if identity.user.persisted? && identity.save
      set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
      sign_in_and_redirect identity.user, event: :authentication
    else
      errors = (identity.user.errors.full_messages + identity.errors.full_messages).join("\n")
      redirect_to new_user_registration_url, alert: errors
    end
  end
end
