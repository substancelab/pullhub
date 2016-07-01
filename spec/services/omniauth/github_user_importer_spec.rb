# frozen_string_literal: true
require "rails_helper"

RSpec.describe Omniauth::GithubUserImporter do
  def do_omniauth
    auth_info = OpenStruct.new(:email => "test@example.com",
                               :name => "new name",
                               :image => "http://img.jpg")
    auth_data = OpenStruct.new(:provider => "facebook",
                               :uid => "1234",
                               :info => auth_info)
    Omniauth::GithubUserImporter.new.run(auth_data)
  end

  describe "new user" do
    it "creates a new user" do
      expect { do_omniauth }.to change(User, :count).by(1)
    end
  end

  describe "existing user" do
    it "does not create a new user" do
      FactoryGirl.create(:user, :email => "test@example.com")
      expect { do_omniauth }.to_not change(User, :count)
    end
  end
end
