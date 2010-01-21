require 'radrails'
require 'escape_snippet'
    
command 'and Insert Terminator + LF' do |cmd|
  cmd.key_binding = 'SHIFT+COMMAND+ENTER'
  cmd.scope = 'source'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :line
  cmd.invoke do |context|
    require 'escape_snippet'
    termchar = ENV['TM_LINE_TERMINATOR'] || ";"
    es($stdin.read()[/^(.*?);*\s*$/, 1]) + "#{es(termchar)}\n$0"
  end
end
