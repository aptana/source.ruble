require 'command_testcase'
require 'move_to_eol_and_insert_lf'

class InsertLFTest < CommandTestCase
  
  def command_name
    'and Insert LF'
  end
  
  def test_insert_lf
    assert_equal("Comment here\n$0", execute("Comment here"))
    assert_output_type(:insert_as_snippet)
  end
end