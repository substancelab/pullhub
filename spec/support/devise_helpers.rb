# frozen_string_literal: true
module DeviseHelpers
  def login_with(user = double("user"), scope = :user)
    current_user = "current_#{scope}".to_sym
    if user.nil?
      guest_login(current_user, scope)
    else
      user_login(current_user, user)
    end
  end

  def user_login(current_user, user)
    allow(request.env["warden"]).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(current_user).and_return(user)
  end

  def guest_login(current_user, scope)
    allow(request.env["warden"]).to receive(:authenticate!).
      and_throw(:warden, :scope => scope)
    allow(controller).to receive(current_user).and_return(nil)
  end

  def stub_env_for_devise
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def stub_env_for_omniauth(email: Faker::Internet.email,
    name: Faker::Name.name)
    stub_env_for_devise
    request.env["omniauth.auth"] = OmniAuth::AuthHash.new(
      "provider" => "github", "uid" => "1234",
      "info" => {"email" => email, "name" => name}
    )
  end
end
