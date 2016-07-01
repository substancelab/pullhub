# frozen_string_literal: true
require "rails_helper"

describe Users::OmniauthCallbacksController do
  describe "#annonymous user" do
    context "when github email doesn't exist in the system" do
      def do_get_github(email: Faker::Internet.email, name: Faker::Name.name)
        stub_env_for_omniauth(:email => email, :name => name)
        get :github
        @user = User.where(:email => email).first
      end

      it "should create a new user " do
        do_get_github
        expect(@user).to_not be_nil
      end

      it "should create user with github id" do
        do_get_github
        user = User.where(:provider => "github", :uid => "1234").first
        expect(user).to_not be_nil
      end

      it "should sign in user" do
        expect(@controller.current_user).to eq(@user)
      end

      it "should redirect to root" do
        do_get_github
        expect(response).to redirect_to root_path
      end
    end
  end

  describe "#logged in user" do
    context "when user don't have github authentication" do
      before(:each) do
        stub_env_for_omniauth

        user = User.create!(:email => "user@example.com",
                            :password => "my_secret")
        sign_in user

        get :github
      end

      it "should add github authentication to current user" do
        user = User.where(:email => "user@example.com").first
        expect(user).to_not be_nil

        fb_authentication = User.where(:provider => "github",
                                       :uid => "1234").first
        expect(fb_authentication).to_not be_nil
        expect(fb_authentication.uid).to eq("1234")
      end

      it { should be_user_signed_in }

      it "should redirect to login" do
        expect(response).to redirect_to root_path
      end
    end

    context "when user already connect with github" do
      before(:each) do
        stub_env_for_omniauth

        user = User.create!(:email => "user@urbanexample.com",
                            :password => "my_secret",
                            :provider => "github",
                            :uid => "1234")
        sign_in user

        get :github
      end

      it "should not add new github authentication" do
        user = User.where(:email => "user@urbanexample.com").first
        expect(user).to_not be_nil

        fb_authentications = User.where(:provider => "github")
        expect(fb_authentications.count).to eq(1)
      end

      it { should be_user_signed_in }

      it "should redirect to root" do
        expect(response).to redirect_to root_path
      end
    end
  end
end
