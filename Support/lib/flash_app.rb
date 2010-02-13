# encoding: utf-8

class FlashApp
  
  attr_reader :name, :path
  
  def initialize()
    find_app
  end
  
  protected
  
  # Find the most recent version of the Flash authoring tool.
  #
  def find_app
    
    [5,4,3].each { |n|
      
      f = "Adobe Flash CS#{n}"
      p = "/Applications/#{f}/#{f}.app"
      
      if File.exist?(p)
        @name = f
        @path = p
        break
      end
      
    }
    
  end
  
end

if __FILE__ == $0
  
  fa = FlashApp.new
  puts fa.name
  puts fa.path
  
end
