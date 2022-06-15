# -*- encoding: utf-8 -*-
# stub: retro 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "retro".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "TODO: Set to your gem server 'https://example.com'", "homepage_uri" => "https://github.com/flatstack-warsaw-dashboard/retro", "source_code_uri" => "https://github.com/flatstack-warsaw-dashboard/retro" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Askarini Zinuretti".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-06-15"
  s.description = "Retro application is retro to help teams make retro process easier.".freeze
  s.email = ["askar.zinurov@flatstack.com".freeze]
  s.homepage = "https://github.com/flatstack-warsaw-dashboard/retro".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.6".freeze)
  s.rubygems_version = "3.1.6".freeze
  s.summary = "This is gem contained shared Retro application code".freeze

  s.installed_by_version = "3.1.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<aws-sdk-dynamodb>.freeze, ["~> 1.74.0"])
  else
    s.add_dependency(%q<aws-sdk-dynamodb>.freeze, ["~> 1.74.0"])
  end
end
