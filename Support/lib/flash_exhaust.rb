# encoding: utf-8

# Parses output from the Flash compiler and html formats it for use with the
# TextMate HTML output window.
#
class FlashExhaust

  # Constants to track switches in matches (to prettify output).
  ERROR_WARN_MATCH = "error_warn_match"
  
  # Instance initialisation. Create's the regex objects once, and set's the 
  # error counter to 0. One instance should be created per Flash compile
  # otherwise the error counter will be inaccurate.
  #
  def initialize()
    
    @error_count = 0
    @last_match = ""
    @raw = ""

    #**Error** /src/Test.as, Line 16: 1095: Syntax error: A string literal must be terminated before the line break.
    @error_and_warn_regex = /\*\*(Error|Warning)\*\*\s(\/.*),\sLine\s([0-9]+):\s([0-9]+):\s(.*)/
    
  end
  
  # Processes a single line of mxmlc compiler output. HTML is generated with 
  # links back to source and configuration files where appropriate.
  #
  def line(str)

    @raw += str
    
    match = @error_and_warn_regex.match(str)
    
    begin
    
      unless match === nil

        print "<br/>" if @last_match != ERROR_WARN_MATCH
        print 'Error ' + match[4] +
              ' <a title="Click to show error." href="txmt://open?url=file://' + match[2] + 
              '&line='+ match[3] + 
              '">' + match[5] + 
              '</a> at line ' + match[3] + 
              ' in <a title="'+ match[2] + 
              '" href="txmt://open?url=file://' + match[2] + '">' +
              File.basename( match[2] ) + '</a><br/>'
        @error_count += 1
        @last_match = ERROR_WARN_MATCH
        return
      end
            
    rescue TypeError
    
      puts "WARNING, TextMate Flash Bundle Error, Unable to parse flash output: <br/><br/>"
      puts "#{str}<br/>"
      
      @error_count += 1
      
    end
  
  end
  
  # This method should be called once compilations is complete. It outputs 
  # formatted html that describes the number of errors encountered.
  #
  def complete
    err = (@error_count == 1) ?  "error" : "errors"
    print "<br/>Build complete, #{ @error_count.to_s } #{err} occured.<br/><br/>"
    print "<div id='flash_output' style='display:none'><pre>#{@raw}</pre><br/></div>"
    print '<div class="controls"><a href="#" onclick="document.getElementById(\'flash_output\').style.display=\'inline\'">show raw output</a></div>'
  end
  
end

if __FILE__ == $0
  
  exhaust = FlashExhaust.new
  
  exhaust.line('**Error** /Users/simon/Desktop/tst/src/Test.as, Line 16: 1095: Syntax error: A string literal must be terminated before the line break.')
  exhaust.line('**Error** /Users/simon/Desktop/tst/src/Test.as, Line 17: 1180: Call to a possibly undefined method deliberateError.')
  exhaust.line('     trace("Test::Test());')
  exhaust.line('**Error** /Users/simon/Desktop/tst/src/Test.as, Line 23: 1083: Syntax error: end of program is unexpected.')
  exhaust.line('**Error** /Users/simon/Desktop/tst/src/Test.as, Line 23: 1084: Syntax error: expecting rightparen before end of program.')
  exhaust.line('**Error** /Users/simon/Desktop/tst/src/Test.as, Line 17: 1180: Call to a possibly undefined method blah.')
  exhaust.line('     blah()')
  #TODO: Following line fails.
  exhaust.line('**Error** Scene 1, Layer \'Layer 1\', Frame 1, Line 1: 1067: Implicit coercion of a value of type String to an unrelated type Number.')
  exhaust.line('Total ActionScript Errors: 1,  Reported Errors: 1')
  
  exhaust.complete

end
