# frozen_string_literal: true
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def github
      user = Omniauth::GithubUserImporter.new.
        run(request.env["omniauth.auth"])

      if user.persisted?
        sign_in_and_redirect user, :event => :authentication
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end

    def failure
      redirect_to root_path
    end
  end
end
