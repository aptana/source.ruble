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
end

# A Block mode Comment
class BlockComment < Comment

  def commented?(lines)
    # Is the input wrapped in the start and end chars?
    input = lines.join("\n").strip
    return input.start_with?(@start_chars) && input.end_with?(@end_chars.rstrip)
  end
  
  def remove(lines)
    output = lines.join("\n")
    Ruble::Logger.trace output
    output = output[(output.index(@start_chars) + @start_chars.size)...output.rindex(@end_chars)]
    Ruble::Logger.trace output

    context.editor[offset, length] = output
    # Retain selection!
    context.editor.selection = [offset, output.length]

    return true
  end
  
  def add(lines)
    Ruble::Logger.trace "Adding block comment: #{to_s}"
    # Wrap entire input in start and end characters of this comment type
    output = "#{@start_chars}#{lines.join("\n")}#{@end_chars}"

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
        output << "\n"
      else
        if l.index(@start_chars)
          output << "#{l[0...index]}#{l[(index + @start_chars.size)..-1]}\n"
        else
          output << "#{l[0...index]}#{l[(index + @start_chars.rstrip.size)..-1]}\n"
        end
      end
    end
    # Remove extra newline at end
    output = output[0...-1]

    context.editor[offset, length] = output
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
          output << "#{l[0...index]}#{@start_chars}#{l[index..-1]}\n"
        else
          output << "#{@start_chars}#{l}\n"
        end
      end
      # Remove extra newline at end
      output = output[0...-1]
    end
    
    context.editor[offset, length] = output
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