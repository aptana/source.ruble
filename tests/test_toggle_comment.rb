require 'command_testcase'
require 'toggle_comment'

class ToggleCommentTest < CommandTestCase
  
  def command_name
    'Comment Line / Selection'
  end

  def teardown
    ENV["TM_COMMENT_START"] = nil
    ENV["TM_SELECTION_OFFSET"] = nil
    ENV["TM_SELECTION_LENGTH"] = nil
    @context['input_type'] = nil
    @context.editor.document = ""
    super
  end
  
  # Add a line comment to selected text
  def test_add_comment_selection_input_line_mode_full_line_selected
    @context['input_type'] = :selection
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "Comment here"
    @context.editor.selection = Selection.new(0, 12, 1, 1)
    
    execute("Comment here")
    assert_equal("# Comment here", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Remove a line comment from selected text
  def test_remove_comment_selection_input_line_mode_full_line_selected
    @context['input_type'] = :selection
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "# Comment here"
    @context.editor.selection = Selection.new(0, 14, 1, 1)
    
    execute("# Comment here")
    assert_equal("Comment here", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Add test for adding line comment when selection in middle of line
  def test_add_comment_selection_input_line_mode_mid_line
    @context['input_type'] = :selection
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "Comment here"
    @context.editor.selection = Selection.new(3, 4, 1, 1)
    
    execute("ment")
    assert_equal("# Comment here", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Add test for removing line comment when selection in middle of line
  def test_remove_comment_selection_input_line_mode_mid_line
    @context['input_type'] = :selection
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "# Comment here"
    @context.editor.selection = Selection.new(4, 4, 1, 1)
    
    execute("mmen")
    assert_equal("Comment here", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Add test for adding line comment when selection spans multiple lines
  def test_add_comment_selection_input_spans_multiple_lines_line_mode
    @context['input_type'] = :selection
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "Comment here\nComment continued"
    @context.editor.selection = Selection.new(0, 30, 1, 2)
    
    execute("Comment here\nComment continued")
    assert_equal("# Comment here\n# Comment continued", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Add test for removing line comment when selection spans multiple lines
  def test_remove_comment_selection_input_spans_multiple_lines_line_mode
    @context['input_type'] = :selection
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "# Comment here\n# Comment continued"
    @context.editor.selection = Selection.new(0, 34, 1, 2)
    
    execute("# Comment here\n# Comment continued")
    assert_equal("Comment here\nComment continued", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Add test adding comment when selection is multiple lines, but starts and ends mid line
  def test_add_comment_selection_input_spans_multiple_lines_mid_line_line_mode
    @context['input_type'] = :selection
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "Comment here\nComment continued"
    @context.editor.selection = Selection.new(3, 24, 1, 2)
    
    execute("ment here\nComment contin")
    assert_equal("# Comment here\n# Comment continued", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Add test removing comment when selection is multiple lines, but starts and ends mid line
  def test_remove_comment_selection_input_spans_multiple_lines_mid_line_line_mode
    @context['input_type'] = :selection
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "# Comment here\n# Comment continued"
    @context.editor.selection = Selection.new(3, 28, 1, 2)
    
    execute("omment here\n# Comment contin")
    assert_equal("Comment here\nComment continued", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # TODO Add tests for when the content is indented, that we retain it!
  
  # Add test for adding line comment with line input
  def test_add_comment_line_input_line_mode
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "Comment here"
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("Comment here")
    assert_equal("# Comment here", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Add test for removing line comment with line input
  def test_remove_comment_line_input_line_mode
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "# Comment here"
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("# Comment here")
    assert_equal("Comment here", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # TODO Add test for removing block comment
end