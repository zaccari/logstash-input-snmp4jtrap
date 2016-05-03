# coding: utf-8

Gem::Specification.new do |s|
  s.name          = 'logstash-input-snmp4jtrap'
  s.version       = '1.0.1'
  s.authors       = ['Michael Zaccari']
  s.email         = ['michael.zaccari@accelerated.com']

  s.summary       = 'Read snmp trap messages as event with SNMP4J'
  s.description   = 'This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install logstash-input-snmp4jtrap. This gem is not a stand-alone program'
  s.homepage      = 'https://github.com/mzaccari/logstash-input-snmp4jtrap'
  s.license       = 'MIT'
  s.require_paths = ['lib']

  # Files
  s.files         = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE.txt']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'input' }

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core-plugin-api', '~> 1.0'
  s.add_runtime_dependency 'logstash-codec-plain'

  s.add_development_dependency 'logstash-devutils'
end
