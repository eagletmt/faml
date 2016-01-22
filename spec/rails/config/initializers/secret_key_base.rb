# frozen_string_literal: true
version = [Rails::VERSION::MAJOR, Rails::VERSION::MINOR]
if version == [4, 0]
  TestApp::Application.configure do
    config.secret_key_base = YAML.load_file(Rails.root.join('config/secrets.yml'))[Rails.env]['secret_key_base']
  end
end
