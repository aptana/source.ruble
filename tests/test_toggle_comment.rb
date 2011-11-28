require 'command_testcase'
require 'toggle_comment'

class ToggleCommentTest < CommandTestCase
  
  def command_name
    'Comment Line / Selection'
  end

  def teardown
    ENV["TM_COMMENT_START"] = nil
    ENV["TM_COMMENT_END"] = nil
    ENV["TM_COMMENT_START_2"] = nil
    ENV["TM_COMMENT_END_2"] = nil
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
    # Select lines we uncommented
    assert_equal(Selection.new(0, 14, 1, 1), @context.editor.selection)
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
    # Select lines we uncommented
    assert_equal(Selection.new(0, 12, 1, 1), @context.editor.selection)
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
    # Select lines we commented
    assert_equal(Selection.new(0, 14, 1, 1), @context.editor.selection)
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
    # Select lines we uncommented
    assert_equal(Selection.new(0, 12, 1, 1), @context.editor.selection)
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
    # Select lines we uncommented
    assert_equal(Selection.new(0, 34, 1, 2), @context.editor.selection)
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
    # Select lines we uncommented
    assert_equal(Selection.new(0, 30, 1, 2), @context.editor.selection)
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
    # Select lines we commented
    assert_equal(Selection.new(0, 34, 1, 2), @context.editor.selection)
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
    # Select lines we uncommented
    assert_equal(Selection.new(0, 30, 1, 2), @context.editor.selection)
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
    # When offset is at beginning of line and no selection, we select the comment we added
    assert_equal(Selection.new(0, 2, 1, 1), @context.editor.selection)
  end
  
  def test_add_comment_line_input_line_mode_caret_mid_line
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "Comment here"
    @context.editor.selection = Selection.new(3, 0, 1, 1)
    
    execute("Comment here")
    assert_equal("# Comment here", @context.editor.document.get)
    assert_output_type(:discard)
    # Keep caret at same place in text (ignoring added comment prefix)
    assert_equal(Selection.new(5, 0, 1, 1), @context.editor.selection)
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
    # When offset is at beginning of line and no selection, we keep caret at beginning of line
    assert_equal(Selection.new(0, 0, 1, 1), @context.editor.selection)
  end
  
  def test_apstud3400
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "# --\n# first-line:"
    @context.editor.selection = Selection.new(5, 0, 2, 2)
    
    execute("# first-line:")
    assert_equal("# --\nfirst-line:", @context.editor.document.get)
    assert_output_type(:discard)
    # When offset is at beginning of line and no selection, we keep caret at beginning of line
    assert_equal(Selection.new(5, 0, 2, 2), @context.editor.selection)
  end
  
  def test_remove_comment_line_input_line_mode_caret_mid_line
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "# Comment here"
    @context.editor.selection = Selection.new(5, 0, 1, 1)
    
    execute("# Comment here")
    assert_equal("Comment here", @context.editor.document.get)
    assert_output_type(:discard)
    # When caret is mid-line, retain it's position (ignoring removed comment prefix)
    assert_equal(Selection.new(3, 0, 1, 1), @context.editor.selection)
  end
  
  def test_add_line_comment_on_whitespace_only_line
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = "    "
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("    ")
    assert_equal("#     ", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  def test_add_line_comment_on_empty_line
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "# "
    @context.editor.document = ""
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("")
    assert_equal("# ", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  def test_remove_line_comment_on_whitespace_only_line
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "// "
    @context.editor.document = "// "
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("// ")
    assert_equal("", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  def test_remove_line_comment_with_removed_trailing_whitespace
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "// "
    @context.editor.document = "//"
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("//")
    assert_equal("", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  def test_remove_line_comment_with_removed_trailing_whitespace_followed_by_contents
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "// "
    @context.editor.document = "//print \"Hello world\";"
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("//print \"Hello world\";")
    assert_equal("print \"Hello world\";", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # Add test for removing block comment
  # def test_remove_block_comment_selection_input_spans_multiple_lines_block_mode
  #   @context['input_type'] = :selection
  #   ENV["TM_COMMENT_START"] = "# "
  #   ENV["TM_COMMENT_START_2"] = "=begin\n"
  #   ENV["TM_COMMENT_END_2"] = "=end\n"
  #   @context.editor.document = "=begin\n Comment here\n=end"
  #   @context.editor.selection = Selection.new(0, 26, 1, 4)
  #   
  #   execute("=begin\n Comment here\n=end")
  #   assert_equal(" Comment here\n", @context.editor.document.get)
  #   assert_output_type(:discard)
  # end
  
  def test_add_block_comment_line_input
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "<!-- "
    ENV["TM_COMMENT_END"] = " -->"
    @context.editor.document = "Comment here"
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("Comment here")
    assert_equal("<!-- Comment here -->", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  def test_remove_block_comment_line_input
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "<!-- "
    ENV["TM_COMMENT_END"] = " -->"
    @context.editor.document = "<!-- Comment here -->"
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("<!-- Comment here -->")
    assert_equal("Comment here", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  def test_remove_block_comment_line_input_missing_surrounding_whitespace
    @context['input_type'] = :line
    ENV["TM_COMMENT_START"] = "<!-- "
    ENV["TM_COMMENT_END"] = " -->"
    @context.editor.document = "<!--comment-->"
    @context.editor.selection = Selection.new(0, 0, 1, 1)
    
    execute("<!--comment-->")
    assert_equal("comment", @context.editor.document.get)
    assert_output_type(:discard)
  end
  
  # TODO Add tests that we retain selection after removing or adding comments, block and line
end