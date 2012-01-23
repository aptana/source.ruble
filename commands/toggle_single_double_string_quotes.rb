require 'ruble'

# FIXME Keybinding doesn't seem to work properly
command t(:toggle_quotes) do |cmd|
  cmd.key_binding = 'CONTROL+M2+\''
  cmd.scope = 'string.quoted.single, string.quoted.double'
  cmd.output = :replace_selection
  cmd.input = :selection, :scope
  cmd.invoke do |context|
    print case str = $stdin.read
      when /\A"(.*)"\z/m; "'" + $1 + "'"
      when /\A'(.*)'\z/m; '"' + $1 + '"'
      else str
    end
  end
end
