require 'java'
require 'ruble'

bundle 'Source' do |bundle|
  bundle.author = 'Christopher Williams'
  bundle.copyright = "© Copyright 2010 Aptana Inc. Distributed under the MIT license."
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

# Extend Ruble::Editor to add special ENV vars
module Ruble
  class Editor
    unless method_defined?(:to_env_pre_source_bundle)
      alias :to_env_pre_source_bundle :to_env
      def to_env
        env_hash = to_env_pre_source_bundle
        scopes = current_scope.split(' ')
        if !scopes.select {|scope| scope.start_with? "source" }.empty?
          # Only do this if some specialized scope hasn't contributed comment starts and ends
          if !env_hash.include? 'TM_COMMENT_START'
            env_hash['TM_COMMENT_START'] ||= "/*"
            env_hash['TM_COMMENT_END'] ||= "*/"
            env_hash['TM_COMMENT_START_2'] ||= "// "
            env_hash['TM_COMMENT_START_3'] ||= "# "
            env_hash['TM_COMMENT_DISABLE_INDENT'] ||= "YES"
          end          
        end
        env_hash
      end
    end
  end
end