require 'ruble'

# TODO Move this class into a lib file and require it in the block of the command!
# Handles generating the comment types from ENV defined by the rubles.
# Also deals with checking if the comment applies to given lines, and deals with adding or removing comments from lines
class Comment
  attr_reader :mode, :context
  
  def initialize(context, start_chars, end_chars, mode, disable_indent)
    @context, @start_chars, @end_chars, @mode = context, start_chars, end_chars, mode
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
      comments << Comment.new(context,
      ENV["TM_COMMENT_START#{suffix}"] || "# ",
      ENV["TM_COMMENT_END#{suffix}"]   || "",
      ENV["TM_COMMENT_MODE#{suffix}"]  || (ENV["TM_COMMENT_END#{suffix}"] ? :block : :line),
      ENV["TM_COMMENT_DISABLE_INDENT#{suffix}"])
    end
    comments
  end

  # Are these lines commented according to this comment's type/rules?
  def commented?(lines)
    Ruble::Logger.trace "Checking if lines are commented by #{to_s}"
    commented = true
    if is_block_mode?
      # Is the input wrapped in the start and end chars?
      input = lines.join("\n").strip
      commented = input.start_with?(@start_chars) and input.end_with?(@end_chars)
    else
      
      if input_is_selection?
        # Expand selection to full line?
        lines = []
        (context.editor.selection.start_line..context.editor.selection.end_line).each {|line_num| lines << context.editor.line(line_num)}
        Ruble::Logger.trace "Expanded to: #{lines}"
      end
      
      # Make sure each line starts with the start_chars
      lines.each do |l|
        return false if !l.strip.start_with?(@start_chars)
      end
    end
    return commented
  end
  
  def to_s
    "<#{@start_chars} comment #{@end_chars}, mode: #{@mode}>"
  end

  def toggle(lines)
    commented?(lines) ? remove(lines) : add(lines)
  end

  def remove(lines)
    Ruble::Logger.trace "Removing comment: #{to_s}"
    output = ''
    if is_block_mode?
      output = lines.join('\n')
      output = output[(output.index(@start_chars) + @start_chars.size)..-1]
      output = output[0..output.rindex(@end_chars)]
    else
      
      if input_is_selection?
        # Expand selection to full line?
        lines = []
        (context.editor.selection.start_line..context.editor.selection.end_line).each {|line_num| lines << context.editor.line(line_num)}
        Ruble::Logger.trace "Expanded to: #{lines}"
      end
      
      # take indent before comment start, then stuff after comment
      lines.each {|l| output << "#{l[0...l.index(@start_chars)]}#{l[(l.index(@start_chars) + @start_chars.size)..-1]}\n" }
      # Remove extra newline at end
      output = output[0...-1]
    end

    context.editor[offset, length] = output
    return true
  end

  def add(lines)
    Ruble::Logger.trace "Adding comment: #{to_s}"
    output = ''
    if is_block_mode?
      # Wrap entire input in start and end characters of this comment type
      output = "#{@start_chars}#{lines.join('\n')}#{@end_chars}"
    else
      
      if input_is_selection?
        # Expand selection to full line?
        lines = []
        (context.editor.selection.start_line..context.editor.selection.end_line).each {|line_num| lines << context.editor.line(line_num)}
        Ruble::Logger.trace "Expanded to: #{lines}"
      end
      
      # Prepend the comment beginning to each line, Retain existing indent (that's the index/regexp thing)!
      lines.each {|l| output << "#{l[0...l.index(/\S/)]}#{@start_chars}#{l[l.index(/\S/)..-1]}\n" }
      # Remove extra newline at end
      output = output[0...-1]
    end

    context.editor[offset, length] = output
    return true
  end
  
  def document
    context.editor.document
  end
  
  def offset
    # Need to calculate offset based on input type, line or selection
    if input_is_selection?
      if is_line_mode?
        context.editor.offset_at_line(context.editor.selection.start_line)
      else
        ENV["TM_SELECTION_OFFSET"].to_i
      end
    else
      context.editor.offset_at_line(context.editor.caret_line)
    end
  end
  
  def length
    # Need to calculate length based on input type, line or selection
    if input_is_selection?
      if is_line_mode?
        (context.editor.offset_at_line(context.editor.selection.end_line) + context.editor.line(context.editor.selection.end_line).length) - offset
      else
        ENV["TM_SELECTION_LENGTH"].to_i
      end
    else
      context.editor.current_line.length
    end
  end
  
  def is_line_mode?
    mode.to_sym == :line
  end
  
  def is_block_mode?
    mode.to_sym == :block
  end
  
  def input_is_selection?
    context['input_type'].to_sym == :selection
  end
end

command 'Comment Line / Selection' do |cmd|
  cmd.key_binding = 'M1+/'
  cmd.output = :discard
  cmd.input = :selection, :line
  cmd.invoke do |context|
    Ruble::Logger.log_level = :trace
    Ruble::Logger.trace "Toggling comment!"
    Ruble::Logger.trace "Input type: #{context['input_type']}"
    Ruble::Logger.trace "Input type selection?: #{context['input_type'].to_sym == :selection}"
    # Take in input. If it spans multiple lines, try to do block commenting, otherwise do normal line commenting
    input = $stdin.read

    Ruble::Logger.trace "Input: #{input}"
    lines = input.split(/\r?\n|\r/)
 
    # Ok, now we know which comments we have...
    comments = Comment.from_env(context)
    Ruble::Logger.trace "Generated comment types from ENV: #{comments}"
    
    # Check if we're selecting multiple lines, if so prefer block comments
    try_modes = [:line]
    try_modes.insert(0, :block) if lines.size > 1 # Ok, we have multiple lines, try the block comments first

    # Remove comments if necessary
    removed_comments = false
    try_modes.each do |mode|
      comments.each do |c|
        next unless c.mode == mode

        if c.commented?(lines)
          c.remove(lines)
          removed_comments = true
          break
        end
      end
      break if removed_comments
    end

    # Looks like we didn't remove, so we need to try adding
    if !removed_comments
      # Textmate never adds block comments, so just try line comments
      # FIXME If we've selected part of a line that has non-whitespace before it, we should probably wrap in block comment!
      comments.each do |c|
        next unless c.mode == :line

        break if c.add(lines)
      end
    end
  end
end
