command 'Newline - \\n' do |s|
  s.key_binding = 'CONTROL+ENTER'
  s.scope = 'source'
  s.input = :none
  s.output = :insert_as_snippet
  # FIXME Cursor should be at end after insertion, but it isn't!
  s.invoke { "\\n" }
end


command 'Double Quotes - \\"...\\"' do |s|
  s.key_binding = 'OPTION+COMMAND+"'
  s.input = :none
  s.output = :insert_as_snippet
  s.invoke do
    if ENV['TM_SELECTED_TEXT'].length > 0
      "\\\"${1:#{ENV['TM_SELECTED_TEXT']}}\\\""
    else
      "\\\"${0}\\\""
    end
  end
end


command 'Single Quotes - \\\'...\\\'' do |s|
  s.key_binding = 'OPTION+COMMAND+\''
  s.input = :none
  s.output = :insert_as_snippet
  s.invoke do
    if ENV['TM_SELECTED_TEXT'].length > 0
      "\\'${1:#{ENV['TM_SELECTED_TEXT']}}\\'"
    else
      "\\'${0}\\'"
    end
  end
end


snippet 'Insert Comment Banner' do |s|
  # FIXME No tab trigger, probably needs to become command
  s.expansion = '${TM_COMMENT_START/\s*$/ /}==${1/(.)|(?m:\n.*)/(?1:=)/g}==${TM_COMMENT_END/^\s*(.+)/ $1/}
${TM_COMMENT_START/\s*$/ /}= ${1:${TM_SELECTED_TEXT:Banner}} =${TM_COMMENT_END/\s*(.+)/ $1/}
${TM_COMMENT_START/\s*$/ /}==${1/(.)|(?m:\n.*)/(?1:=)/g}==${TM_COMMENT_END/\s*(.+)/ $1/}'
end


