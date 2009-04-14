#!/usr/bin/env ruby -wKU

# Object respresenting a JavaScript Flash Document.
#
class JSFLDoc
  
  attr_reader :path, :log
  
  def initialize()
    
    @path = '/tmp/flash_mate.jsfl'
    @log = '/tmp/flash_mate.log'
    
    @content = []
    
  end
  
  # Output the current content to file.
  #  
  def to_file
    js = File.new(@path,'w')
    js.print @content.join("\n")
    js.flush
  end
  
  # Output the current content to string.
  #
  def to_s
    @content.join("\n")
  end
  
  # =====================
  # = Compile Commands  =
  # =====================
  
  # Test the currently active Fla.
  #
  def test
    header
    clear_panels
    @content << "var doc = fl.getDocumentDOM();"
    @content << "doc.testMovie();"
    write_log
    to_file
  end
  
  # Publish the currently active Fla.
  #
  def publish
    header
    clear_panels
    @content << "fl.getDocumentDOM().publish();"
    write_log
    to_file
  end
  
  # Compile the requested Fla.
  #
  def compile(src,swf)
    @content << "var sourceFile = \"#{e_uri(src)}\";"
    @content << "var outputFile = \"#{e_uri(swf)}\";"
    @content << "var doc = fl.openDocument(sourceFile);"
    @content << "doc.exportSWF(outputFile, true);"
  end  
  
  # Experiment to find out if it is possible to dynamically create a fla, set the
  # document class on the fly then publish/test it.
  #
  def create_fla

    @content << "var doc = fl.createDocument();"    

    @content << "fl.as3PackagePaths = \".;/test/path/to/src\";" 
    @content << "fl.trace(fl.as3PackagePaths);"
    
    @content << "doc.docClass = \"Test\""
    @content << "doc.frameRate = \"30\""
    
  end
  
  # ==========
  # = Output =
  # ==========
  
  def trace_msg(msg)
    @content << "fl.trace('#{msg}');"
  end
  
  def clear_panels
    @content << "fl.outputPanel.clear();" 
    @content << "fl.compilerErrors.clear();"
  end
  
  def write_log
    @content << "var logFile = \"#{e_uri(@log)}\";"
    @content << "fl.outputPanel.save(logFile);"
    @content << "fl.compilerErrors.save(logFile, true);"
  end
  
  # =============
  # = Utilities =
  # =============
  
  # Write file header.
  #
  def header
    @content << "/"*80
    @content << "//"
    @content << "// Generated by FlashMate"
    @content << "//"
    @content << "/"*80 + "\n"
  end
  
  # Convert file path to file uri.
  #
  def e_uri(path)
    "file://#{path}"
  end
  
  
end
