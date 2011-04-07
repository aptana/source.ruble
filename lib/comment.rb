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
    return input.start_with?(@start_chars) && input.end_with?(@end_chars)
  end
  
  def remove(lines)
    output = ''
    output = lines.join('\n')
    output = output[(output.index(@start_chars) + @start_chars.size)..-1]
    output = output[0..output.rindex(@end_chars)]

    context.editor[offset, length] = output
    return true
  end
  
  def add(lines)
    # Wrap entire input in start and end characters of this comment type
    output = "#{@start_chars}#{lines.join('\n')}#{@end_chars}"

    context.editor[offset, length] = output
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
      context.editor.current_line.length
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
    
    # Make sure each line starts with the start_chars
    lines.each { |l| return false if !l.strip.start_with?(@start_chars) }
    
    return true
  end
  
  def remove(lines)
    lines = expanded_lines(lines)
    
    # take indent before comment start, then stuff after comment
    output = ''
    lines.each {|l| output << "#{l[0...l.index(@start_chars)]}#{l[(l.index(@start_chars) + @start_chars.size)..-1]}\n" }
    # Remove extra newline at end
    output = output[0...-1]

    context.editor[offset, length] = output
    return true
  end
  
  def add(lines)
    lines = expanded_lines(lines)
    
    # Prepend the comment beginning to each line, Retain existing indent (that's the index/regexp thing)!
    output = ''
    lines.each {|l| output << "#{l[0...l.index(/\S/)]}#{@start_chars}#{l[l.index(/\S/)..-1]}\n" }
    # Remove extra newline at end
    output = output[0...-1]

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
      (context.editor.offset_at_line(context.editor.selection.end_line) + context.editor.line(context.editor.selection.end_line).length) - offset
    else
      context.editor.current_line.length
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