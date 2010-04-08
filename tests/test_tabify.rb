require 'command_testcase'
require 'tabify'
require 'tempfile'

class TabifyTest < CommandTestCase
  
  def command_name
    'Convert Spaces to Tabs (Estimating Indent)'
  end
  
  def teardown
    super
    ENV['TM_TAB_SIZE'] = nil
    ENV['TM_FILEPATH'] = nil
  end
  
  def test_tabify
    ENV['TM_TAB_SIZE'] = "2"    
    input =<<EOL
no indent
  one indent
    two indents
      three indents
        four indents
EOL
    expected = "no indent\n\tone indent\n\t\ttwo indents\n\t\t\tthree indents\n\t\t\t\tfour indents\n"
    
    file = Tempfile.new("tabify")
    File.open(file.path, 'w') {|f| f.puts(input) }
    ENV['TM_FILEPATH'] = file.path
    assert_equal(expected, execute(input))
    assert_output_type(:replace_document)
  end
end