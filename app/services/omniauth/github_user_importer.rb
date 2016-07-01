# frozen_string_literal: true
module Omniauth
  class GithubUserImporter
    def run(auth)
      user = User.where(:provider => auth.provider, :uid => auth.uid).
        or(User.where(:email => auth.info.email)).first

      create_user_if_necessary(auth, user)
    end

    private

    def create_user_if_necessary(auth, user)
      if user.nil?
        user = User.create(
          :provider => auth.provider,
          :uid => auth.uid,
          :email => auth.info.email,
          :password => Devise.friendly_token
        )
      end
      user
    end
  end
end
