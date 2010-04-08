require 'ruble'
    
command 'and Insert Terminator' do |cmd|
  cmd.key_binding = 'OPTION+COMMAND+ENTER'
  cmd.scope = 'source'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :line
  cmd.invoke do |context|
    require 'escape_snippet'
    termchar = ENV['TM_LINE_TERMINATOR'] || ";"
    es($stdin.read()[/^(.*?);*\s*$/, 1]) + "#{es(termchar)}$0"
  end
end
