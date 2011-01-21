require 'ruble'

def out(*args)
  print( *args.map do |arg|
    escaped = e_sn(arg)
    $selected ? escaped.gsub("}", "\\}") : escaped.sub("\0", "${0}")
  end )
end

command 'Comment Line / Selection' do |cmd|
  cmd.key_binding = 'M1+/'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :line
  cmd.invoke do |context|
    require 'escape'
    # by James Edward Gray II <james (at) grayproductions.net>
    
    # 
    # To override the operation of this command for your language add a Preferences
    # bundle item that defines the following variables as appropriate for your
    # language:
    # 
    #   TM_COMMENT_START - the character string that starts comments, e.g. /*
    #   TM_COMMENT_END   - the character string that ends comments (if appropriate),
    #                      e.g. */
    #   TM_COMMENT_MODE  - the type of comment to use - either 'line' or 'block'
    # 
        
    # find all available comment variables
    var_suffixes = [""]
    2.upto(1.0/0.0) do |n|
      if ENV.include? "TM_COMMENT_START_#{n}"
        var_suffixes << "_#{n}"
      else
        break
      end
    end
    
    text    = $stdin.read
    default = nil  # the comment we will insert, if none are removed
    
    # maintain selection
    if text == ENV["TM_SELECTED_TEXT"]
      $selected = true
      print "${1:"
    else
      $selected = false
    end
    
    # try a removal for each comment...
    var_suffixes.each do |suffix|
      # build comment
      com = { :start     => ENV["TM_COMMENT_START#{suffix}"] || "# ",
              :end       => ENV["TM_COMMENT_END#{suffix}"]   || "",
              :mode      => ENV["TM_COMMENT_MODE#{suffix}"]  ||
                            (ENV["TM_COMMENT_END#{suffix}"] ? "block" : "line"),
              :no_indent => ENV["TM_COMMENT_DISABLE_INDENT#{suffix}"] }
      
      com[:esc_start], com[:esc_end] = [com[:start], com[:end]].map do |str|
        str.gsub(/[\\|()\[\].?*+{}^$]/, '\\\\\&').
            gsub(/\A\s+|\s+\z/, '(?:\&)?')
      end
      
      # save the first one as our insertion default
      default = com if default.nil?
      
      # try a removal
      case com[:mode]
      when "line"  # line by line comment
        if text !~ /\A[\t ]+\z/ &&
           text.send(text.respond_to?(:lines) ? :lines : :to_s).
                map { |l| !!(l =~ /\A\s*(#{com[:esc_start]}|$)/) }.uniq == [true]
          if $selected
            out text.gsub( /^(\s*)#{com[:esc_start]}(.*?)#{com[:esc_end]}(\s*)$/,
                           '\1\2\3' )
            print "}"
            exit 0
          else
            r = text.sub( /^(\s*)#{com[:esc_start]}(.*?)#{com[:esc_end]}(\s*)$/,
                          '\1\2\3' )
            i = ENV["TM_LINE_INDEX"].to_i
            i = i > text.index(/#{com[:esc_start]}/)            ?
                [[0, i - com[:start].length].max, r.length].min :
                [i, r.length].min
            r[i, 0] = "\0"
            out r
            exit 0
          end
        end
      when "block" # block comment
        regex = /\A(\s*)#{com[:esc_start]}(.*?)#{com[:esc_end]}(\s*)\z/m
        if text =~ regex
          if $selected
            out text.sub(regex, '\1\2\3')
            print "}"
            exit 0
          else
            r = text.sub(regex, '\1\2\3')
            i = ENV["TM_LINE_INDEX"].to_i
            i = i > text.index(/#{com[:esc_start]}/)            ?
                [[0, i - com[:start].length].max, r.length].min :
                [i, r.length].min
            r[i, 0] = "\0"
            out r
            exit 0
          end
        end
      end
    end
    
    # none of our removals worked, so perform an insert (minding indent setting)
    text[ENV["TM_LINE_INDEX"].to_i, 0] = "\0" unless $selected or text.empty?
    case default[:mode]
    when "line"  # apply comment line by line
      # modify text to expand to include beginning of first line when we're turning comments on in line mode!
      if $selected
        line_number = ENV["TM_SELECTION_START_LINE_NUMBER"].to_i - 1
        line_offset = ENV["TM_LINE_INDEX"].to_i
        if line_offset > 0
          prefix = context.editor.line(line_number)[0, line_offset]
          text = prefix + text
          cur_selection = context.editor.selection
          context.editor.selection = [cur_selection.offset - line_offset, cur_selection.length + line_offset]
        end
      end
      if text.empty?
        out "#{default[:start]}\0#{default[:end]}"
      elsif default[:no_indent]
        out text.gsub(/^.*$/, "#{default[:start]}\\&#{default[:end]}")
      elsif text =~ /\A([\t ]*)\0([\t ]*)\z/
        out text.gsub(/^.*$/, "#{$1}#{default[:start]}#{$2}#{default[:end]}")
      else
        indent = text.scan(/^[\t \0]*(?=\S)/).
                      min { |a, b| a.length <=> b.length } || ""
        text.send(text.respond_to?(:lines) ? :lines : :to_s).map do |line|
          if line =~ /^(#{indent})(.*)$(\n?)/ then
            out $1 + default[:start] + $2 + default[:end] + $3
          elsif line =~ /^(.*)$(\n?)/ then
            out indent + default[:start] + $1 + default[:end] + $2
          end
        end
      end
    when "block" # apply comment around selection
      if text.empty?
        out default[:start]
        print "${0}"
        out default[:end]
      elsif text =~ /\A([\t ]*)\0([\t ]*)\z/
        out $1, default[:start]
        print "${0}"
        out $2, default[:end]
      elsif default[:no_indent]
        out default[:start], text, default[:end]
      else
        lines = text.to_a
        if lines.empty?
          out default[:start], default[:end]
        else
          lines[-1].sub!(/^(.*)$/, "\\1#{default[:end]}")
          out lines.shift.sub(/^([\s\0]*)(.*)$/, "\\1#{default[:start]}\\2")
          out(*lines) unless lines.empty?
        end
      end
    end
    print "}" if $selected
    nil
  end
end
