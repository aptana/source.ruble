require 'ruble'

# FIXME Doesn't like the comment.line scope. We probably aren't matching scopes properly again!
command t(:reformat_comment) do |cmd|
  cmd.key_binding = 'CONTROL+Q'
#  cmd.scope = 'comment.line'
  cmd.output = :insert_as_snippet
  cmd.input = :selection, :scope
  cmd.invoke do |context|
    ctext = $stdin.read
    if ctext =~ /^\s*(.[^\s\w\\]*\s*)/
      cstring = $1
    else
      context.exit_show_tool_tip("Unable to determine comment character.")
    end
    
    flags = %Q{-p "#{cstring}"}
    flags += " --retabify" unless ENV["TM_SOFT_TABS"] == "YES"
    
    require "escape"
    require 'rbconfig'

    if RbConfig::CONFIG['target_os'] =~ /(win|w)32$/
      command = "ruby \"#{e_sn(ENV["TM_BUNDLE_SUPPORT"])}\\bin\\rubywrap.rb\" #{flags}"
    else
      command = "ruby #{e_sh(ENV["TM_BUNDLE_SUPPORT"])}/bin/rubywrap.rb #{flags}"
    end

    text = IO.popen(command, "r+") do |wrapper|
      wrapper << ctext
      wrapper.close_write
      wrapper.read
    end
    
    print e_sn(text)
  end
end
