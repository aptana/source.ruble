require 'ruble'

command t(:comment_line) do |cmd|
  cmd.key_binding = ["M1+/", "M1+7", "M1+M2+C"]
  cmd.output = :discard
  cmd.input = :selection, :line
  cmd.invoke do |context|
    # Ruble::Logger.log_level = :trace
    Ruble::Logger.trace "Toggling comment!"
    Ruble::Logger.trace "Input type: #{context['input_type']}"
    Ruble::Logger.trace "Input type selection?: #{context['input_type'].to_sym == :selection}"
    # Take in input. If it spans multiple lines, try to do block commenting, otherwise do normal line commenting
    input = $stdin.read

    Ruble::Logger.trace "Input: #{input}"
    lines = input.split(/\r?\n|\r/)
 
    # Ok, now we know which comments we have...
    require 'comment'
    comments = Comment.from_env(context)
    Ruble::Logger.trace "Generated comment types from ENV: #{comments}"
    
    # Check if we're selecting multiple lines, if so prefer block comments
    try_modes = [:line]
    if lines.size > 1
      # Ok, we have multiple lines, try the block comments first
      try_modes.insert(0, :block)
    else
      try_modes << :block
    end

    # Remove comments if necessary
    removed_comments = false
    try_modes.each do |mode|
      comments.each do |c|
        next unless c.mode == mode

        if c.commented?(lines)
          Ruble::Logger.trace "Found comment match, going to remove: #{c}"
          c.remove(lines)
          removed_comments = true
          break
        end
      end
      break if removed_comments
    end

    # Looks like we didn't remove, so we need to try adding
    if !removed_comments
      added_comments = false
      # try line comments first
      [:line, :block].each do |mode|
        comments.each do |c|
          next unless c.mode == mode
  
          if c.add(lines)
            added_comments = true
            break
          end
        end
        break if added_comments
      end
    end
  end
end
