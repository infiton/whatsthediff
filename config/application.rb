require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# loads in config/application.yml to store configuration
if File.exists?(File.expand_path('../application.yml', __FILE__))
  config = YAML.load(File.read(File.expand_path('../application.yml', __FILE__))).fetch(Rails.env, {})
  APP_CONFIG = HashWithIndifferentAccess.new(config)
end

module Whatsthediff
  class Application < Rails::Application
    config.active_job.queue_adapter = :delayed_job
    config.assets.precompile += ['lib/*', 'knockout/*']
  end
end
