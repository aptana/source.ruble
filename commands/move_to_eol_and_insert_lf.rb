require 'ruble'
    
command t(:insert_lf) do |cmd|
  cmd.key_binding = 'M1+ENTER'
  cmd.scope = 'source'
  cmd.output = :discard
  cmd.input = :line
  cmd.invoke do |context|
    line = context.editor.selection.start_line
    offset = context.editor.offset_at_line(line) + $stdin.read.length
    context.editor[offset, 0] = "\n"
  end
end
