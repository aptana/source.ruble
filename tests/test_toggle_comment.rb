require 'command_testcase'
require 'toggle_comment'

class ToggleCommentTest < CommandTestCase
  
  def command_name
    'Comment Line / Selection'
  end
  
  def teardown
    super
    ENV["TM_COMMENT_START"] = nil
    ENV["TM_LINE_INDEX"] = nil
  end
  
  def test_toggle_comment_on
    ENV["TM_COMMENT_START"] = "# "
    assert_equal("${0}# Comment here", execute("Comment here"))
    assert_output_type(:insert_as_snippet)
  end
  
  def test_toggle_comment_off
    ENV["TM_COMMENT_START"] = "# "
    ENV["TM_LINE_INDEX"] = "14"
    assert_equal("Comment here${0}", execute("# Comment here"))
    assert_output_type(:insert_as_snippet)
  end
end