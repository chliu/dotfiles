#!/usr/bin/ruby
require 'rubygems'
require 'irb/completion'
require 'irb/ext/save-history'
require 'interactive_editor'
require 'looksee'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:PROMPT_MODE] = :SIMPLE


begin
  require "ap"
  IRB::Irb.class_eval do
    def output_value
      ap @context.last_value
    end
  end
rescue LoadError => e
  puts "ap gem not found.  Try typing 'gem install awesome_print' to get super-fancy output."
end


%w[rubygems looksee/shortcuts wirble].each do |gem|
  begin
    require gem
  rescue LoadError
  end
end

class Object
  # list methods which aren't in superclass
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
  
  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex("exit") || -1
  content = history[(index+1)..-2].join("\n")
  puts content
  copy content
end

def paste
  `pbpaste`
end

# Clear the screen
def clear
  system 'clear'
  if ENV['RAILS_ENV']
    return "Rails environment: " + ENV['RAILS_ENV']
  else
    return "No rails environment - happy hacking!";
  end
end
 
# Shortcuts
alias c clear

load File.dirname(__FILE__) + '/.railsrc' if $0 == 'irb' && ENV['RAILS_ENV']

class << self
  def vi(name=nil)
     InteractiveEditor.edit('/Applications/MacVim.app/Contents/MacOS/Vim', name)
  end

  def vim(name=nil)
     InteractiveEditor.edit('/Applications/MacVim.app/Contents/MacOS/Vim', name)
  end

  def gvim(name=nil)
    InteractiveEditor.edit('/Applications/MacVim.app/Contents/MacOS/Vim -g -f', name)
  end
  
  def mate(name=nil)
    InteractiveEditor.edit('mate -w', name)
  end

end
