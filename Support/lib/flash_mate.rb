#!/usr/bin/env ruby -wKU

SUPPORT = 
BUNDLE_LIB = File.expand_path(File.dirname(__FILE__))

require BUNDLE_LIB + '/flash_app'
require BUNDLE_LIB + '/flash_exhaust'
require BUNDLE_LIB + '/jsfl_doc'

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
    @verbose = false
    
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
  
  # Create a jsfl test document and execute it.
  #  
  def test
    jsfl.test
    execute
  end
  
  # Create a jsfl publish document and execute it.
  #
  def publish
    jsfl.publish
    execute
  end
  
  # Compiles the fla specified by TM_FLA.
  #
  def compile

    fla = ENV['TM_FLA'] || nil
    swf = ENV['TM_SWF'] || swf_from_fla(fla)

    if File.exists?(fla.to_s)
      jsfl.compile(fla,swf)
      execute      
    else
      puts "<h2>Error</h2><p>Please specify the fla document you wish to compile using the environment variable <code>$TM_FLA</code>.
			<br>
			<br>
			Configuration help can be found <a href=\"tm-file://#{ENV['TM_BUNDLE_SUPPORT']}/html/help.html#conf\">here.</a></p>"
    end
        
  end
  
  private

  # Run the currently configured JSFLDoc.
  #
  def execute
   
   sh = "osascript -e 'tell application \"#{flash.name}\" to open posix file \"#{jsfl.path}\"'"
   
   puts "Calling Flash"
   puts "Executing Command : #{sh}" if @verbose
   
   `#{sh}`
   
   counter = 0
   while(true)
     
     puts "."
     
     break if File.exist?(jsfl.log)
     
     if counter >= timeout
       print "Timeout waiting for Flash to respond (#{counter} Seconds)<br/>"
       break
     end
     
     counter += 1
     sleep 1
     
   end
   
   puts "<br/>"
   puts "Checking Flash Output<br/>"
   
   begin
     
     exhaust = FlashExhaust.new

     IO.foreach(jsfl.log, "\r") do |line|
       exhaust.line(line)
     end
     
     exhaust.complete
     
   rescue Exception => e
     puts "Error manipulating log file.<br/> #{e}"
     puts "Exiting.<br/>"
   end

   File.delete(jsfl.path)
   File.delete(jsfl.log)
   
  end
  
  # Calculate the name of the swf from the fla.
  #
  def swf_from_fla(path)
    return nil if path.nil?
    path.sub(/\.fla$/,',swf')
  end
  
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

  #fm.test
  #fm.publish
  fm.to_s

  #`mate #{fm.jsfl.path}`
  
end
