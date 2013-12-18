# Base class. This is not meant to be instantiated, instead we generate the special LineComment/BlockComment subclasses

class Comment
  attr_reader :context
  
  def initialize(context, start_chars, end_chars, disable_indent)
    @context, @start_chars, @end_chars = context, start_chars, end_chars
    @disable_indent = (disable_indent == 'YES')
  end

  def Comment.from_env(context)
    comments = []

    suffixes = ['']
    2.upto(1.0/0.0) do |n|
      if ENV.include? "TM_COMMENT_START_#{n}"
        suffixes << "_#{n}"
      else
        break
      end
    end

    suffixes.each do |suffix|
      mode = ENV["TM_COMMENT_MODE#{suffix}"] || (ENV["TM_COMMENT_END#{suffix}"] ? :block : :line)
      type = (mode == :block) ?  BlockComment : LineComment
      comments << type.new(context,
        ENV["TM_COMMENT_START#{suffix}"] || "# ",
        ENV["TM_COMMENT_END#{suffix}"]   || "",
        ENV["TM_COMMENT_DISABLE_INDENT#{suffix}"])
    end
    comments
  end

  # Are these lines commented according to this comment's type/rules?
  def commented?(lines)
    # Implement in child classes
  end

  def remove(lines)
    # Implement in child classes
  end

  def add(lines)
    # Implement in child classes
  end
  
  def toggle(lines)
    commented?(lines) ? remove(lines) : add(lines)
  end
  
  def document
    context.editor.document
  end
  
  def offset
    context.editor.offset_at_line(context.editor.caret_line)
  end
  
  def length
    context.editor.current_line.length
  end
  
  def input_is_selection?
    context['input_type'].to_sym == :selection
  end
  
  def to_s
    "#{@start_chars}Comment#{@end_chars}"
  end

  def newline
    document.nil? ? "\n" : document.getDefaultLineDelimiter
  end
end

# A Block mode Comment
class BlockComment < Comment

  def commented?(lines)
    # Is the input wrapped in the start and end chars?
    input = lines.join(newline).strip
    return input.start_with?(@start_chars.rstrip) && input.end_with?(@end_chars.lstrip)
  end
  
  def remove(lines)
    output = lines.join(newline)
    Ruble::Logger.trace output
    
    # try finding end of comment with/without trailing whitespaces in start comment block
    index = output.index(@start_chars)
    start = 0
    if index
      start = index + @start_chars.size
    else
      index = output.index(@start_chars.rstrip)
      start = index + @start_chars.rstrip.size
    end
    
    whitespaces_before = output[0, index]
    
    # Now try finding end block comment, with/without whitespaces
    after_comment = output.rindex(@end_chars)
    unless after_comment
      after_comment = output.rindex(@end_chars.lstrip)
    end
    
    output = output[start...after_comment]
    output = whitespaces_before + output
    Ruble::Logger.trace output

    context.editor[offset, length] = output
    # Retain selection!
    context.editor.selection = [offset, output.length]

    return true
  end
  
  def add(lines)
    Ruble::Logger.trace "Adding block comment: #{to_s}"
    # Wrap entire input in start and end characters of this comment type
    
    line0 = lines[0]
    lines[0] = line0.lstrip
    whitespaces_before = line0[0,line0.length - lines[0].length]
    output = "#{whitespaces_before}#{@start_chars}#{lines.join(newline)}#{@end_chars}"

    context.editor[offset, length] = output
    # Retain selection!
    context.editor.selection = [offset, output.length]

    return true
  end
  
  def offset
    if input_is_selection?
      ENV["TM_SELECTION_OFFSET"].to_i
    else
      context.editor.offset_at_line(context.editor.caret_line)
    end
  end
  
  def length
    if input_is_selection?
      ENV["TM_SELECTION_LENGTH"].to_i
    else
      region = context.editor.document.getLineInformation(context.editor.caret_line)
      region.length
      #context.editor.line_information(context.editor.caret_line).length
    end
  end
  
  def mode
    :block
  end
end

# A Line mode comment
class LineComment < Comment

  def commented?(lines)
    lines = expanded_lines(lines)
    return false if lines.empty?
    
    # Make sure each line starts with the start_chars
    lines.each { |l| return false if l.lstrip.length == 0 || !l.lstrip.start_with?(@start_chars.rstrip) }
    
    return true
  end
  
  def remove(lines)
    lines = expanded_lines(lines)
    
    # take indent before comment start, then stuff after comment
    output = ''
    lines.each do |l|
      index = l.index(@start_chars.rstrip)
      # If the whitespace after comment chars is removed, we should just remove the part without whitespace
      if l.size < @start_chars.size
        output << newline
      else
        output << "#{l[0...index]}"
        if l.index(@start_chars)
          output << l[(index + @start_chars.size)..-1]
        else
          output << l[(index + @start_chars.rstrip.size)..-1]
        end
        output << newline
      end
    end
    # Remove extra newline at end
    output = output[0...-(newline.length)]
    # Offset's value will change once we edit the contents...
    replace_start = offset
    selection = context.editor.selection
    selection_offset = selection.offset
    start_of_line = context.editor.offset_at_line(selection.start_line)
    context.editor[replace_start, length] = output
    if input_is_selection?
      # Select the uncommented code
      context.editor.selection = [replace_start, output.length]
    else
      # Keep caret in same place ignoring comment. Don't go past beginning of line.
      context.editor.selection = [[selection_offset - @start_chars.size, start_of_line].max, 0]
    end
    return true
  end
  
  def add(lines)
    Ruble::Logger.trace "Adding line comment: #{to_s}"
    lines = expanded_lines(lines)
    
    output = ''
    if lines.empty?
      output = @start_chars
    else
      # Prepend the comment beginning to each line, Retain existing indent (that's the index/regexp thing)!
      lines.each do |l|
        next unless l
        index = l.index(/\S/)
        if index
          output << "#{l[0...index]}#{@start_chars}#{l[index..-1]}#{newline}"
        else
          output << "#{@start_chars}#{l}#{newline}"
        end
      end
      # Remove extra newline at end
      output = output[0...-(newline.length)]
    end
    # Offset's value will change once we edit the contents...
    replace_start = offset
    selection_offset = context.editor.selection.offset
    column = context.editor.caret_column
    context.editor[replace_start, length] = output
    # Handle selection/caret
    if input_is_selection?
      # Select the newly commented code
      context.editor.selection = [replace_start, output.length]
    else
      # FIXME What if cursor was at zero column? Then we want to make selection start there, but select the added comment prefix!
      if column == 0
        context.editor.selection = [selection_offset, @start_chars.length]
      else
        # move cursor back to same spot in line
        context.editor.selection = [selection_offset + @start_chars.length, 0]
      end
    end
    return true
  end
  
  def offset
    if input_is_selection?
      context.editor.offset_at_line(context.editor.selection.start_line)
    else
      context.editor.offset_at_line(context.editor.caret_line)
    end
  end
  
  def length
    if input_is_selection?
      (context.editor.offset_at_line(context.editor.selection.end_line) + (context.editor.line(context.editor.selection.end_line) || '').length) - offset
    else
      (context.editor.current_line || '').length
    end
  end
  
  # Expands to full lines if this is a selection, since we shouldn't apply line comments mid-line
  def expanded_lines(lines)
    if input_is_selection?
      lines = []
      (context.editor.selection.start_line..context.editor.selection.end_line).each {|line_num| lines << context.editor.line(line_num)}
      Ruble::Logger.trace "Expanded to: #{lines}"
    end
    lines
  end
  
  def mode
    :line
  end
end