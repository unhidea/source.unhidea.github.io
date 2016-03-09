require "rubygems"
require 'rake'
require 'yaml'
require 'time'

CONFIG['idea'] = {
 'input_path' => File.join(SOURCE, "idea-crawler","dist"),
  'output_path'=> File.join(SOURCE ),
}
def replaceFile(file,text)
  pre = ""
  post = ""
  open(file, 'r') do |f|
    flag=0
    while (line = f.gets)
      if flag == 0
        pre += line
        if line.start_with?("#idea-begin")
          flag = 1
        end 
      elsif flag == 1
        if line.start_with?("#idea-end")
          post += line
          flag = 2
        end 
      elsif flag == 2
        post += line
      end 
    end
  end
#  puts pre
#  puts post
  open(file,'w') do |f|
    f.puts pre
    f.puts text
    f.puts post
  end
end
namespace :idea do
  
  # Public: Create idea files. 
  #
  # TODO Automactically detect if an idea is changed
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
   
    # generate index.html 
    index_ideas =[]
    Dir.glob("#{input_path}/*") do |filepath|
      ideaname = File.basename(filepath,".yml") 
      index_idea={
        "name" => ideaname,
        "title" => "ideas."+ideaname+".unhidea.name"
      }
      index_ideas.push(index_idea)
    end
    
    index_yaml = {
      'ideas' => index_ideas
    }
    index_yaml_str = YAML.dump(index_yaml)[4..-1]    #remove separator ---
    replaceFile(File.join(output_path,'index.html'),index_yaml_str) 
    
    # end generate index.html

    # generate ideas/{ideaname}.html for each idea 
    Dir.glob("#{input_path}/*") do |filepath|
      ideaname = File.basename(filepath,".yml") 
      idea_forks =[]
      idea_yaml ={
        "title" => ideaname,
        "ideas" => idea_forks
      }

      puts "Generating idea: '#{ideaname}'"
      ideas = YAML.load(File.read(filepath))
      for idea in ideas
        if idea["language"] == "en"
          fork = {
            "fork" => idea["fork"],
            "name" => "ideas."+ideaname+"."+idea["fork"]+".name",
            "tags" =>  "ideas."+ideaname+"."+idea["fork"]+".tags",
          }
          idea_forks.push(fork)
        end
          
      end
      idea_yaml_str = YAML.dump(idea_yaml)[4..-1]    #remove separator ---
      replaceFile(File.join(output_path,'ideas',ideaname+'.html'),idea_yaml_str) 
    end
    # generate ideas/{ideaname}.html for each idea 

    
    # generate ideas/{ideaname}.html for each idea 
    lang_ideas_map={}

    Dir.glob("#{input_path}/*") do |filepath|
      ideaname = File.basename(filepath,".yml") 
      ideas = YAML.load(File.read(filepath))
      for idea in ideas
        fork = idea['fork']
        lang = idea["language"]
        if not lang_ideas_map[lang]
          ideas_map={}
          lang_ideas_map[lang] ={
              "ideas" => ideas_map
          } #ideas
        elsif
          ideas_map = lang_ideas_map[lang]["ideas"]
        end
        
        forks_map=ideas_map[ideaname]
        if not forks_map
          forks_map=ideas_map[ideaname] ={} #forks
        end
        
        fork_meta={
          "id" => idea["id"],
          "name" => idea["title"],
          "tags" => idea["keywords"] 
        }
        forks_map[fork]=fork_meta
      end
    end
    
    lang_ideas_map.each do |lang, value|
      lang_yaml_str = YAML.dump(value)[4..-1]    #remove separator ---
      replaceFile(File.join(output_path,'_i18n',lang+".yml"),lang_yaml_str) 
     end 
    # generate ideas/{ideaname}.html for each idea 

   
    
    puts "=> idea created successfully"
    
   
  end # task :create
end # namespace idea
