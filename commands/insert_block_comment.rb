require 'ruble'
require 'escape'

def find_markers
  10.times do |n|
    start = ENV["TM_COMMENT_START#{"_#{n}" if n > 0}"].to_s.strip
    stop  = ENV["TM_COMMENT_END#{"_#{n}"   if n > 0}"].to_s.strip
    return start, stop if not start.empty? and not stop.empty?
  end
  return [nil, nil]
end
    
command 'Insert Block Comment' do |cmd|
  cmd.key_binding = 'OPTION+COMMAND+/'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :none
  cmd.invoke do |context|    
    start, stop = find_markers
    context.exit_show_tool_tip "No block comment markers found for this language." if start.nil?
    input = STDIN.read
    
    if input =~ /\n/
      start << "\n"
      stop  << "\n"
    end
    
    STDOUT << e_sn(start) << (input.empty? ? "\n\t$0\n" : e_sn(input)) << e_sn(stop)
    nil
  end
end
