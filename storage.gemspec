require File.expand_path("../lib/storage/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "storage"
  s.version     = Storage::VERSION
  s.authors     = ["Jon Bracy"]
  s.email       = ["jonbracy@gmail.com"]
  s.homepage    = "https://github.com/malomalo/storage"
  s.summary     = %q{A simple API for multiple storage backends like B2, S3, and the FileSystem}
  s.description = %q{A simple API for multiple storage backends like B2, S3, and the FileSystem}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Developoment 
  s.add_development_dependency 'rake'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'mocha'

  # Runtime
  s.add_runtime_dependency 'terrapin'
end
