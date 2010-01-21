require 'radrails'
require 'escape_snippet'
    
command 'and Insert LF' do |cmd|
  cmd.key_binding = 'COMMAND+ENTER'
  cmd.scope = 'source'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :line
  cmd.invoke do |context|
    es($stdin.read()[/^(.*?);*\s*$/, 1]) + "\n$0"
  end
end
