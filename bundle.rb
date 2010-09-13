require 'java'
require 'ruble'

bundle do |bundle|
  bundle.author = 'Christopher Williams'
  bundle.copyright = "© Copyright 2010 Aptana Inc. Distributed under the MIT license."
  bundle.display_name = 'Source'
  bundle.description =  <<END
A port of the TextMate bundle.

Miscellaneous support for working with source code. This bundle is essential, e.g. it allows you to toggle comments on ?/.
END
  bundle.repository = "git://github.com/aptana/source.ruble.git"
  
  bundle.menu 'Source' do |main_menu|
    main_menu.menu 'Folding' do |folding_menu|
      folding_menu.command 'Expand'
      folding_menu.command 'Collapse'
      folding_menu.command 'Expand All'
      folding_menu.command 'Collapse All'
      folding_menu.menu 'Toggle Foldings at Level' do |toggle_level|
        toggle_level.command 'All Levels'
        1.upto(9).each {|i| toggle_level.command i.to_s }
      end
    end    
    main_menu.menu 'Comments' do |submenu|
      submenu.command 'Comment Line / Selection'
      submenu.command 'Insert Block Comment'
      submenu.separator
      submenu.command 'Insert Comment Banner'
      submenu.command 'Insert Comment Header'
      submenu.command 'Reformat Comment'
    end
    main_menu.menu 'Insert Escaped' do |submenu|
      submenu.command 'Single Quotes - \\\'...\\\''
      submenu.command 'Double Quotes - \\"...\\"'
      submenu.command 'Newline - \\n'
    end
    main_menu.separator
    main_menu.command 'Toggle Single / Double String Quotes'
    main_menu.command 'Toggle camelCase / snake_case / PascalCase'
    main_menu.separator
    main_menu.menu 'Move to EOL' do |submenu|
      submenu.command 'and Insert LF'
      submenu.command 'and Insert Terminator'
      submenu.command 'and Insert Terminator + LF'
    end
    main_menu.separator
    main_menu.command 'Align Assignments'
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