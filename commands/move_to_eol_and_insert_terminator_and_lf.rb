require 'ruble'
    
command t(:insert_terminator_and_lf) do |cmd|
  cmd.key_binding = 'M1+M2+ENTER'
  cmd.scope = 'source'
  cmd.output = :discard
  cmd.input = :line
  cmd.invoke do |context|
    # FIXME To match TextMate, we should insert terminator at end of selection if there is one, but EOL at end of line
    termchar = ENV['TM_LINE_TERMINATOR'] || ";"
    line = context.editor.selection.start_line
    offset = context.editor.offset_at_line(line) + $stdin.read.length
    context.editor[offset, 0] = termchar
    context.editor[offset + 1, 0] = "\n"
  end
end
