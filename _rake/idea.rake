require "rubygems"
require 'rake'
require 'yaml'
require 'time'

CONFIG['idea'] = {
  'input_path' => File.join(SOURCE, "idea-crawler","dist"),
  'output_path'=> File.join(SOURCE, "_i18n"),
}

namespace :idea do
  
  # Public: Create idea files. 
  #
  # name - String, name of the idea you want to create from yaml info.
  #        If not given, then generate all ideas from input_path
  #
  # Examples
  #
  #   rake idea:create name="idea"
  #
  # Returns Success/failure messages.
  desc "Create idea files."
  task :create do
    input_path = CONFIG['idea']['input_path']
    output_path = CONFIG['idea']['output_path']
    abort("rake aborted: '#{input_path}' directory not found.") unless FileTest.directory?(input_path)
    abort("rake aborted: '#{output_path}' directory not found.") unless FileTest.directory?(output_path)

    name = ENV["name"]

    Dir.glob("#{input_path}/*") do |filepath|
      ideaname = File.basename(filepath,".yml") 
      if name == nil or ideaname == name.to_s 
        puts "Generating idea: '#{ideaname}'"
        ideas = YAML.load(File.read(filepath))
        for idea in ideas
          open(File.join(output_path,idea["language"],"ideas",ideaname+'.html'), 'w') do |page|
            page.puts '<a href="'+idea["url"]+'">'+idea["fork"]+'</a>'
          end    
        end
      end
    end
    
    puts "=> idea created successfully"
  end # task :create
end # namespace idea
