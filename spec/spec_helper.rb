require "codeclimate-test-reporter"
CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']

# Dir.glob('./lib/**/*.rb').each { |f| require f }

require_relative '../lib/factor-connector-api.rb'