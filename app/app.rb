class Instanat < Padrino::Application
  register SassInitializer
  use ActiveRecord::ConnectionAdapters::ConnectionManagement
  register Padrino::Rendering
  register Padrino::Helpers

  configure do
    config = YAML.load_file("./global_config.yml") rescue nil || {}

    set :photos_to_display, config["photos_to_display"]

  end
  
end
