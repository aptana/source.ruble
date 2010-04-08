require 'command_testcase'
require 'insert_block_comment'

class InsertBlockCommentTest < CommandTestCase
  
  def command_name
    'Insert Block Comment'
  end
  
  def teardown
    super
    ENV["TM_COMMENT_START"] = nil
    ENV["TM_COMMENT_END"] = nil
  end
  
  def test_no_markers
    assert_equal("No block comment markers found for this language.", execute('camelCase'))
    assert_output_type(:show_as_tooltip)
  end
  
  def test_insert_block
    ENV["TM_COMMENT_START"] = "==begin\n" # FIXME Not sure why, but I need to set two equals for one to show up in actual value!
    ENV["TM_COMMENT_END"] = "==end\n"
    assert_equal("=begin\nComment here\n=end\n", execute("Comment here\n"))
    assert_output_type(:insert_as_snippet)
  end
end