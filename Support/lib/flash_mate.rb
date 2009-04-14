#!/usr/bin/env ruby -wKU

require 'flash_app'
require 'jsfl_doc'

# Ruby interface for Flash.
#
class FlashMate
  
  VERSION = "0.0.1"
  
  attr_reader :flash, :jsfl, :timeout
  attr_accessor :fla, :swf
  
  def initialize
    
    @flash   = FlashApp.new
    @jsfl    = JSFLDoc.new

    @timeout = 10
    @src     = ''
    @swf     = ''
    @fla     = ''
    
  end
  
  # Proxy method to call to_file on currently held JSFLDoc object.
  #
  def to_file
    
    begin
      @jsfl.to_file
    rescue Exception => e
      puts "Error creating JSFL file."
      puts "Exiting"
    end
    
  end
  
  # Proxy method to call to_s on currently held JSFLDoc object.
  #
  def to_s
    print @jsfl.to_s
  end
  
  # Display version string. 
  #
  def version
    puts "FlashMate #{VERSION}"
  end
  
  def test
    jsfl.test
  end

  def publish
    jsfl.publish
  end
  
  # Run the currently configured JSFLDoc.
  #
  def execute
   
   sh = "osascript -e 'tell application \"#{flash.name}\" to open posix file \"#{jsfl.path}\"'"
   
   puts "Calling Flash"
   puts "Executing Command : " + sh
   
   `#{sh}`
   
   counter = 0
   while(true)
     
     puts "."
     
     break if File.exist?(jsfl.log)
     
     if counter >= timeout
       print "Timeout waiting for Flash to respond (#{counter} Seconds)"
       break
     end
     
     counter += 1
     sleep 1
     
   end
   
   puts ""
   puts "Checking Flash Output"
   
   begin
     IO.foreach(jsfl.log) do |line|
       puts line
      end     
   rescue Exception => e
     puts "Error manipulating log file."
     puts "Exiting"
   end

   #File.delete(jsfl.path)   
   #File.delete(jsfl.log)
   
  end
  
  private
  
  # Display command line useage information (if a cli is ever implemented).
  #
  # http://optiflag.rubyforge.org/why.html#one.4
  # http://raa.ruby-lang.org/project/getopt/
  #
  def usage
      puts "usage: flashmate -e | -c | -p [-v] [-x] (-s <sourcefile>) ([-o] <exportpath>) ([-t] <timeout>)([-d] <tempdir>) [-j]

Options and arguments:
-a : Prints version and about information.
-c : Specifies save and compact action.
-d : Specifies temp directory that will be used for temporary files. Optional.
-e : Specifies export action.
-h : Prints usage information.
-j : Specifies that the generated JSFL file should be printed. If this option is specified, Flash will not be executed.
-o : Specifies the output file if -e flag is also set. Optional. If not specified, file will be output to same directory as source.
-p : Specifies publish action.
-s : Specifies source file. Required.
-t : Specifies timeout value. Optional.
-v : Specifies verbose mode. Optional.
-f : Specifies that the Flash authoring version installed is a version other than Flash CS3
-x : Specifies whether Flash should be closed after it is done processing. Optional."

  end  

end

if __FILE__ == $0
  
  fm = FlashMate.new
  fm.fla = "/Users/simon/Desktop/tst/Test.fla"
  fm.swf = "/Users/simon/Desktop/tst/bin/Test.swf"

  # fm.test
  fm.publish
  fm.to_s

  fm.execute
  
  #`mate #{fm.jsfl.path}`
  
end
