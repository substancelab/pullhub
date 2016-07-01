# frozen_string_literal: true
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Pullhub
  class Application < Rails::Application
  end
end
