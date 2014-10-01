# encoding: UTF-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'factor-connector-api'
  s.version       = '0.0.3'
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Maciej Skierkowski']
  s.email         = ['maciej@factor.io']
  s.homepage      = 'https://factor.io'
  s.summary       = 'Timer Factor.io Connector'
  s.description   = 'Timer Factor.io Connector'
  
  s.files         = Dir.glob('./lib/**/*.rb')
  
  s.require_paths = ['lib']

  s.add_runtime_dependency 'addressable', '~> 2.3.6'
  s.add_runtime_dependency 'rubyzip', '~> 1.1.6'
  s.add_runtime_dependency 'rest-client', '~> 1.7.2'
  s.add_runtime_dependency 'celluloid', '~> 0.16.0'

end