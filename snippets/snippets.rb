require 'ruble'

command t(:newline) do |s|
  s.key_binding = 'CONTROL+ENTER'
  s.scope = 'source'
  s.input = :none
  s.output = :insert_as_snippet
  s.invoke { "\\n" }
end


command t(:double_quotes) do |s|
  s.key_binding = 'OPTION+COMMAND+\''
  s.input = :none
  s.output = :insert_as_snippet
  s.invoke do
    if ENV['TM_SELECTED_TEXT'].length > 0
      "\\\"${1:#{ENV['TM_SELECTED_TEXT']}}\\\""
    else
      "\\\"$0\\\""
    end
  end
end


command t(:single_quotes) do |s|
  s.key_binding = 'OPTION+COMMAND+\''
  s.input = :none
  s.output = :insert_as_snippet
  s.invoke do
    if ENV['TM_SELECTED_TEXT'].length > 0
      "\\'${1:#{ENV['TM_SELECTED_TEXT']}}\\'"
    else
      "\\'$0\\'"
    end
  end
end


command t(:insert_comment_banner) do |s|
  s.key_binding = 'CONTROL+SHIFT+B'
  s.input = :none
  s.output = :insert_as_snippet
  s.invoke do
    selected = ENV['TM_SELECTED_TEXT'] || 'Banner'
    selected = 'Banner' if selected.length == 0
    spacer = "=" * selected.length
    comment_start = ENV['TM_COMMENT_START']
    comment_end = ENV['TM_COMMENT_END']
    # FIXME We don't do transformations so our space doesn't dynamically adjust as user changes message
"#{comment_start} ==#{spacer}== #{comment_end}
#{comment_start} = ${1:#{selected}} = #{comment_end}
#{comment_start} ==#{spacer}== #{comment_end}"
  end
end


