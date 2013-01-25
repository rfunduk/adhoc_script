# -*- encoding: utf-8 -*-
require File.expand_path('../lib/adhoc_script', __FILE__)

Gem::Specification.new do |gem|
  gem.authors        = ["Ryan Funduk"]
  gem.email          = ["ryan.funduk@gmail.com"]
  gem.description    = %q{A simple wrapper class for running adhoc scripts on sets of data.}
  gem.summary        = %q{}
  gem.homepage       = "http://github.com/rfunduk/adhoc_script"

  gem.executables    = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files          = `git ls-files`.split("\n")
  gem.test_files     = `git ls-files -- test/*`.split("\n")
  gem.name           = "adhoc_script"
  gem.require_paths  = ["lib"]
  gem.version        = '0.0.1'
end
