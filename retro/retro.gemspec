# frozen_string_literal: true

require_relative "lib/retro/version"

Gem::Specification.new do |spec|
  spec.name = "retro"
  spec.version = Retro::VERSION
  spec.authors = ["Askarini Zinuretti"]
  spec.email = ["askar.zinurov@flatstack.com"]

  spec.summary = "This is gem contained shared Retro application code"
  spec.description = "Retro application is retro to help teams make retro process easier."
  spec.homepage = "https://github.com/flatstack-warsaw-dashboard/retro"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.6"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/flatstack-warsaw-dashboard/retro"
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "aws-sdk-dynamodb", "~>1.74.0"

  # Web dependencies
  spec.add_dependency "jsonapi-serializer", ">= 2.2.0"
  spec.add_dependency "jwt", ">= 2.3.0"
end
