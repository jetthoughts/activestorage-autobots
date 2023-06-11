# frozen_string_literal: true

require "rails"
require "rails/railtie"

require "active_storage/autobots"

module ActiveStorage
  module Autobots
    class Railtie < Rails::Railtie # :nodoc:
    end
  end
end
