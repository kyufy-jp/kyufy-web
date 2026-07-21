require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KyufyWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # pgvector's vector() column type and its indexes (from the mounted kyufy_core
    # engine) can't be represented in Ruby schema.rb; use structure.sql so they
    # round-trip exactly.
    config.active_record.schema_format = :sql

    # Japanese-monolingual app (SPEC §4): no locale switching, but Rails-generated
    # strings (validation errors, date/number helpers) must come out in Japanese.
    config.i18n.default_locale = :ja
    config.i18n.available_locales = [ :ja ]

    config.time_zone = "Tokyo"
  end
end
