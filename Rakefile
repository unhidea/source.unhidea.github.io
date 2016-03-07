require "rubygems"
require 'rake'

SOURCE = "."
CONFIG = {
  #base
  'version' => "0.1.0",
  'layouts' => File.join(SOURCE, "_layouts"),
  'posts' => File.join(SOURCE, "_posts"),
  'includes' => File.join(SOURCE, "_includes"),
}


desc "Launch preview environment"
task :preview do
  system "jekyll serve -w"
end # task :preview

#Load custom rake scripts
Dir['_rake/*.rake'].each { |r| load r }
