require 'ruble'

bundle do |bundle|
  bundle.author = 'Christopher Williams'
  bundle.copyright = "Copyright 2011 Appcelerator Inc. Distributed under the MIT license."
  bundle.display_name = t(:bundle_name)
  bundle.description =  'A port of the TextMate bundle. Miscellaneous support for working with source code. This bundle is essential, e.g. it allows you to toggle comments on ?/.'
  bundle.repository = "git://github.com/aptana/source.ruble.git"
  
  bundle.menu t(:bundle_name) do |main_menu|
    main_menu.menu t(:folding) do |folding_menu|
      folding_menu.menu t(:toggle_foldings_at_level) do |toggle_level|
        toggle_level.command t(:all_levels)
        1.upto(9).each {|i| toggle_level.command i.to_s }
      end
    end    
    main_menu.menu t(:comments) do |submenu|
      submenu.command t(:comment_line)
      submenu.command t(:insert_block_comment)
      submenu.separator
      submenu.command t(:insert_comment_banner)
      submenu.command t(:insert_comment_header)
      submenu.command t(:reformat_comment)
    end
    main_menu.menu t(:insert_escaped) do |submenu|
      submenu.command t(:single_quotes)
      submenu.command t(:double_quotes)
      submenu.command t(:newline)
    end
    main_menu.separator
    main_menu.command t(:toggle_quotes)
    main_menu.command t(:toggle_case)
    main_menu.separator
    main_menu.menu t(:move_to_eol) do |submenu|
      submenu.command t(:insert_lf)
      submenu.command t(:insert_terminator)
      submenu.command t(:insert_terminator_and_lf)
    end
    main_menu.separator
    main_menu.command t(:align_assignments)
  end
end

# add special ENV vars
env "source" do |e|
  # Only do this if some specialized scope hasn't contributed comment starts and ends
  if !e.include? 'TM_COMMENT_START'
    e['TM_COMMENT_START'] ||= "/*"
    e['TM_COMMENT_END'] ||= "*/"
    e['TM_COMMENT_START_2'] ||= "// "
    e['TM_COMMENT_START_3'] ||= "# "
    e['TM_COMMENT_DISABLE_INDENT'] ||= "YES"
  end
end

# Smart character pairs option
smart_typing_pairs['source'] = ['"', '"', '(', ')', '{', '}', '[', ']', "'", "'", '`', '`']
smart_typing_pairs['string.quoted.double, comment'] = ['"', '"', '(', ')', '{', '}', '[', ']']