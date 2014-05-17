require 'ruble'

command 'Match Brackets' do |cmd|
  cmd.key_binding = 'CTRL+SHIFT+P','CTRL+5'
  cmd.scope = 'source','meta.brace'
  cmd.output = :output_to_console
  cmd.input = :none
  cmd.invoke do |context|

    #define
    doc = context.editor.document
    caret_offset = ENV['TM_CARET_OFFSET'].to_i
    
    symbols = {
    "{" => {:direction => "open", :type => "curly"},
    "}" => {:direction => "close", :type => "curly"},
    "[" => {:direction => "open", :type => "square"},
    "]" => {:direction => "close", :type => "square"},
    "(" => {:direction => "open", :type => "round"},
    ")" => {:direction => "close", :type => "round"}
    } 
    braces = {
    "curly" => {:start => "\\{", :end => "\\}"},
    "square" => {:start => "\\[", :end => "\\]"},
    "round" => {:start => "\\(", :end => "\\)"}
    }
    
    #check matching char
    result = 1 #NOT FOUND
    for i in [-1,0,1]
      if caret_offset + i >= 0
        word = doc.char(caret_offset + i).chr
        result = (word =~ /[\{\}\(\)\[\]]/)
        if (result == 0)
          direction = symbols[word][:direction]
          type = symbols[word][:type]
          caret_offset += i;
          break
        end
      end 
    end 
    #if no braces
    if(result != 0)
      #exit 
      break
    end
    
    #debug
    #CONSOLE.puts "current: #{caret_offset}"
    #CONSOLE.puts "scope  : #{context.editor.current_scope}"
    #CONSOLE.puts "length : #{symbols[word].to_a.join(' ')}"
    
    #get content to find offset of matching brace
    double_quote_regex = /\"([^\"]|(\\\"[^\"(\\\")]*\\\"))*\"/
    single_quote_regex = /\'([^\']|(\\\'[^\'(\\\')]*\\\'))*\'/
    if direction == "open"
      last_offset = doc.length - caret_offset
      content = doc.get(caret_offset, last_offset)
      braces_regex = /^(?<brace_expression>#{braces[type][:start]}([^#{braces[type][:start]}#{braces[type][:end]}\"\']|\g<brace_expression>|(#{double_quote_regex})|(#{single_quote_regex}))*#{braces[type][:end]})/
    else
      content = doc.get(0, caret_offset+1)
      braces_regex = /(?<brace_expression>#{braces[type][:start]}([^#{braces[type][:start]}#{braces[type][:end]}\"\']|\g<brace_expression>|(#{double_quote_regex})|(#{single_quote_regex}))*#{braces[type][:end]})$/
    end
    
    #NOT FOUND
    result = (content =~ braces_regex)
    if  (result == nil) or (result > 0 and direction == "open")
      #EXIT
      break
    end
    
    #find pair of brace
    first_match = []
    last_match = []
    content.scan braces_regex do |result|
      if first_match == []
        first_match = result
        last_match = result
      else
        last_match = result
      end
    end
      
    substr = (direction == "open")? first_match[0] : last_match[0]
    result = (direction == "open")? content.index(substr) : content.rindex(substr)
    if(result == nil)
      break
    end
    
    #simplify result
    result = {:start => result, :length => substr.length}
    
    #CONSOLE.puts result
    #CONSOLE.puts first_match, last_match
    
    #calculate offset to move
    offset_to_move = (direction == "open")? caret_offset + result[:length] : result[:start] + 1
    
    #calculate line 
    line_to_move = doc.line_of_offset(offset_to_move)
    column_to_move = offset_to_move - doc.line_offset( line_to_move )
    
    Ruble::Editor.go_to({ :line => line_to_move + 1, :column => column_to_move + 1})
  end
end

# Use Commands > Bundle Development > Insert Bundle Section > Command
# to easily add new commands