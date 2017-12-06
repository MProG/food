require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

UsdaNutrientDatabase.configure do |config|
  config.batch_size = 20000 # import batch size, if using activerecord-import
  config.perform_logging = true # default false
  config.logger = Rails.logger # default Logger.new(STDOUT)
  config.usda_version = 'sr28' # default sr28
end
require 'activerecord-import/base'
ActiveRecord::Import.require_adapter('postgresql')

# You may want to disable logging during this process to avoid dumping huge SQL
# strings in to your logs
ActiveRecord::Base.logger = Logger.new('/dev/null')

module Food
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/services)
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
