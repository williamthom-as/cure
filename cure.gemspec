# frozen_string_literal: true

require_relative "lib/cure/version"

Gem::Specification.new do |spec|
  spec.name = "cure"
  spec.version = Cure::VERSION
  spec.authors = ["william"]
  spec.email = ["me@williamthom.as"]

  spec.summary = "Cure provides the ability to transform CSVs using descriptive templates."
  spec.description = "Transform, select, anonymize or manipulate data inside CSV files with templates."
  spec.homepage = "https://www.github.com/williamthom-as/cure"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "simplecov"
  spec.add_dependency "artii"
  spec.add_dependency "faker"
  spec.add_dependency "rcsv"
  spec.add_dependency "terminal-table"
end
