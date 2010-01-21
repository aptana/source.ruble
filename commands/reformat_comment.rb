require 'radrails'
require "escape"

command 'Reformat Comment' do |cmd|
  cmd.key_binding = 'CONTROL+M2+q'
  cmd.scope = 'comment.line'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :scope
  cmd.invoke do |context|
    ctext = STDIN.read
    if ctext =~ /^\s*(.[^\s\w\\]*\s*)/
      cstring = $1
    else
      context.exit_show_tool_tip("Unable to determine comment character.")
    end
    
    flags = %Q{-p "#{cstring}"}
    flags += " --retabify" unless ENV["TM_SOFT_TABS"] == "YES"
    
    command = "ruby #{e_sh(ENV["TM_BUNDLE_SUPPORT"])}/bin/rubywrap.rb #{flags}"
    text    = open("| #{command}", "r+") do |wrapper|
      wrapper << ctext
      wrapper.close_write
      wrapper.read
    end
    
    print e_sn(text)
  end
end
