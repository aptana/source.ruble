require 'command_testcase'
require 'move_to_eol_and_insert_terminator_and_lf'

class InsertTerminatorTest < CommandTestCase
  
  def command_name
    'and Insert Terminator + LF'
  end
  
  def teardown
    super
    ENV['TM_LINE_TERMINATOR'] = nil
  end
  
  def test_insert_terminator
    @context.editor.document = "Comment here"
    execute("Comment here")
    assert_equal("Comment here;\n", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  def test_insert_env_terminator
    ENV['TM_LINE_TERMINATOR'] = "."
    @context.editor.document = "Comment here"
    execute("Comment here")
    assert_equal("Comment here.\n", @context.editor.document.get)
    assert_output_type(:discard)
  end
end