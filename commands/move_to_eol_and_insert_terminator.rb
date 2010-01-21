require 'radrails'
# short for escape_snippet - escapes special snippet characters in str
def es(str)
  str.to_s.gsub(/([$`\\])/, "\\\\\\1")
end

command 'and Insert Terminator' do |cmd|
  cmd.key_binding = 'OPTION+COMMAND+ENTER'
  cmd.scope = 'source'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :line
  cmd.invoke do |context|
    termchar = ENV['TM_LINE_TERMINATOR'] || ";"
    es($stdin.read()[/^(.*?);*\s*$/, 1]) + "#{es(termchar)}$0"
  end
end
