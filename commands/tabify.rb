require 'ruble'

command t(:spaces_to_tabs) do |cmd|
  cmd.key_binding = 'CONTROL+SHIFT+COMMAND+T'
  cmd.output = :replace_document
  cmd.input = :document
  cmd.invoke do |context|
    # This is a little more convoluted than it needs to be
    # just to ensure that we can do an OK job on really long
    # files.  Frankly, it's probably all for nothing given
    # that we likely have plenty of memory, and that Ruby will
    # probably go an cache a whole chunk of the file somewhere in
    # the IO pipeline anyway - but we like to make the effort.
    
    # FIXME I think the editor code is converting the tabs right back into spaces! We probably need to force it off...
    spacing = nil
    lines = []
    line = $stdin.gets
    while(line != nil)
    	lines << line
    	if(line =~ /^\t/)  # mixed tabs with spaces, use TM's tab setting
    		spacing = ENV['TM_TAB_SIZE']
    		break
    	elsif(line =~ /^[ ]+\S/)
    		spacing = line[/^([ ]+)\S/, 1].length
    		break
    	end
    
    	line = $stdin.gets
    end
    
    if(spacing != nil)
    	fp = IO.popen("cat \"#{ENV['TM_FILEPATH']}\" | unexpand -t #{spacing}", "r")
    	line = fp.gets
    	while(line != nil)
    		print line
    		line = fp.gets
    	end
    else
    	lines.each { |line| print line }
    
    	line = $stdin.gets
    	while(line != nil)
    		print line
    		line = $stdin.gets
    	end
    end
  end
end
