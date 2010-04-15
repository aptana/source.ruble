require 'command_testcase'
require 'move_to_eol_and_insert_lf'

class InsertLFTest < CommandTestCase
  
  def command_name
    'and Insert LF'
  end
  
  def test_insert_lf
    @context.editor.document = "Comment here"
    execute("Comment here")
    assert_equal("Comment here\n", @context.editor.document.get)
    assert_output_type(:discard)
  end
end