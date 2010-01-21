require 'java'
require 'radrails'

bundle 'Source' do |bundle|
  bundle.author = 'Allan Odgaard'
  bundle.contact_email_rot_13 = 'gz-ohaqyrf@znpebzngrf.pbz'
  bundle.description =  <<END
Miscellaneous support for working with source code. This bundle is essential, e.g. it allows you to toggle comments on ?/.
END
  bundle.repository = "git://github.com/aptana/source-rbundle.git"
  
  bundle.menu 'Source' do |main_menu|
    main_menu.menu 'Comments' do |submenu|
      submenu.command 'Comment Line / Selection'
      submenu.command 'Insert Block Comment'
      submenu.separator
      submenu.command 'Insert Comment Banner'
      submenu.command 'Insert Comment Header'
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

# Extend RadRails::Editor to add special ENV vars
module RadRails
  class Editor
    alias :to_env_pre_source_bundle :to_env
    def to_env
      env_hash = to_env_pre_source_bundle
      scopes = current_scope.split(' ')
      if !scopes.select {|scope| scope.start_with? "source" }.empty?
        env_hash['TM_COMMENT_START'] = "/*"
        env_hash['TM_COMMENT_END'] = "*/"
        env_hash['TM_COMMENT_START_2'] = "// "
        env_hash['TM_COMMENT_START_3'] = "# "
        env_hash['TM_COMMENT_DISABLE_INDENT'] = "YES"
      end
      env_hash
    end
  end
end