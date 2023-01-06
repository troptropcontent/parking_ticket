# frozen_string_literal: true

require_relative 'lib/parking_ticket/version'

Gem::Specification.new do |spec|
  spec.name = 'parking_ticket'
  spec.version = ParkingTicket::VERSION
  spec.authors = ['Tom Ecrepont']
  spec.email = ['tomecrepont@gmail.com']

  spec.summary = 'Never forget to take a parking ticket again.'
  spec.description = 'Automatically renew your parking ticket when it expires.'
  spec.homepage = 'https://github.com/troptropcontent/parking_ticket'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/troptropcontent/parking_ticket'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # dependancies
end
