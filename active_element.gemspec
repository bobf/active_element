# frozen_string_literal: true

require_relative 'lib/active_element/version'

Gem::Specification.new do |spec|
  spec.name = 'active_element'
  spec.version = ActiveElement::VERSION
  spec.authors = ['Bob Farrell']
  spec.email = ['git@bob.frl']

  spec.licenses = ['MIT']
  spec.summary = 'HTML component framework for Rails'
  spec.description = 'Provides boilerplate for common HTML components for front end applications.'
  spec.homepage = 'https://github.com/bobf/active_element'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_runtime_dependency 'bootstrap', '~> 5.3.0alpha3'
  spec.add_runtime_dependency 'kaminari', '~> 1.2'
  spec.add_runtime_dependency 'paintbrush', '~> 0.1.2'
  spec.add_runtime_dependency 'rails', '>= 6.0'
  spec.add_runtime_dependency 'rouge', '~> 4.1'
  spec.add_runtime_dependency 'sassc', '~> 2.4'
end
