require 'ruble'

command t(:insert_comment_header) do |cmd|
  cmd.trigger = 'head'
  cmd.output = :insert_as_snippet
  cmd.input = :none
  cmd.invoke do |context|
    #
    # Notes:
    #
    # '(c)' is legally ambiguous. '©' is not ambiguous, but may cause problems for some compilers.
    # The copyright symbol is redundant if the word 'Copyright' is present, so it's safe to omit it
    # entirely.
    #
    
    file_placeholder = '${1:<file>}'
    project_placeholder = '${2:<project>}'
    
    tm_filename		= ENV['TM_FILENAME']			|| file_placeholder
    tm_project_dir	= ENV['TM_PROJECT_DIRECTORY']	|| ''
    comment_start 	= ENV['TM_COMMENT_START']		|| ''
    comment_end		= ENV['TM_COMMENT_END'] 		|| ''
    copyright_holder	= ENV['TM_ORGANIZATION_NAME']
    
    project = case tm_project_dir
    when /.*\/(.*)/
    	project = Regexp.last_match(1)
    when /C:\\.*\\(.*)/
      project = Regexp.last_match(1)
    else
    	project_placeholder
    end
    
    # use line comments?
    line_comment	= ''
    indent		= ' ' * (comment_start.length + 1)
    
    if comment_end.empty?
    	line_comment = comment_start
    	comment_start = ''
    	comment_end = ''
    	indent = ' '
    end
    
    username	= ENV['TM_FULLNAME']
    date		= Time.now.strftime("%Y-%m-%d").chomp
    
    
    
    # Default to username if no organization name
    copyright_holder ||= username
    
print %Q{#{line_comment}#{comment_start}
#{line_comment}#{indent}#{tm_filename}
#{line_comment}#{indent}#{project}
#{line_comment}#{indent}
#{line_comment}#{indent}Created by #{username} on #{date}.
#{line_comment}#{indent}Copyright #{Time.now.year} #{copyright_holder}. All rights reserved.
#{line_comment}#{comment_end}
$0}
  end
end
