require 'ruble'

command t(:insert_block_comment) do |cmd|
  cmd.key_binding = 'M1+M2+/'
  cmd.key_binding.mac = 'M1+M3+/'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :none
  cmd.invoke do |context|
    require 'block_comment'
    start, stop = find_markers
    context.exit_show_tool_tip "No block comment markers found for this language." if start.nil?
    input = $stdin.read
    
    if input =~ /\n/
      start << "\n"
      stop  << "\n"
    end
    
    require 'escape'
    $stdout << e_sn(start) << (input.empty? ? "\n\t$0\n" : e_sn(input)) << e_sn(stop)
    nil
  end
end
