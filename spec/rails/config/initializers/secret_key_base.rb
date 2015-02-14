case [Rails::VERSION::MAJOR, Rails::VERSION::MINOR]
when [3, 2]
  TestApp::Application.configure do
    config.secret_token = SecureRandom.uuid
end
when [4, 0]
  TestApp::Application.configure do
    config.secret_key_base = YAML.load_file(Rails.root.join('config/secrets.yml'))[Rails.env]['secret_key_base']
  end
end
