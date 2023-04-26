require_relative 'lib/rooute_checker/version'

Gem::Specification.new do |spec|
  spec.name          = "rooute_checker"
  spec.version       = RoouteChecker::VERSION
  spec.authors = ["essei0-0"]
  spec.email = ["hello.essei@gmail.com"]

  spec.summary       = "check root and route"
  spec.description   = "you can check root and route of a point in app"
  spec.homepage = "https://github.com/essei0-0/rooute_checker"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/essei0-0/rooute_checker"
  spec.metadata["changelog_uri"] = "https://github.com/essei0-0/rooute_checker"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
