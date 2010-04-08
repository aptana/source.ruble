require 'command_testcase'
require 'reformat_comment'

class ReformatCommentTest < CommandTestCase
  
  def command_name
    'Reformat Comment'
  end
  
  def teardown
    super
    ENV["TM_SOFT_TABS"] = nil
  end
  
  def test_reformat_comment
    ENV["TM_SOFT_TABS"] = "YES"
    input = " # This is a comment that wraps a round the lines here blah dee dah. This sucks here. Why can't I just type and have it come out all right."
    expected = " # This is a comment that wraps a round the lines here blah dee dah. This\n # sucks here. Why can't I just type and have it come out all right.\n"
    assert_equal(expected, execute(input))
    assert_output_type(:insert_as_snippet)
  end
  
  def test_empty
    assert_equal("Unable to determine comment character.", execute(""))
    assert_output_type(:show_as_tooltip)
  end
end