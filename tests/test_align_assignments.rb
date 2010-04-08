require 'command_testcase'
require 'align_assignments'

class AlignAssignmentsTest < CommandTestCase
  
  def command_name
    'Align Assignments'
  end
  
  def teardown
    super
    ENV["TM_SELECTED_TEXT"] = nil
    ENV["TM_LINE_NUMBER"] = nil
  end

  def test_align_assignments
    input =<<EOL
       start_on = ENV["TM_LINE_NUMBER"].to_i
       block_top = lines.length + 1
       block_bottom = 0
       search_top = 1
       search_bottom = lines.length
       search_failed = false
EOL
    ENV["TM_SELECTED_TEXT"] = input
    ENV["TM_LINE_NUMBER"] = "1"
    expected =<<EOL
       start_on      = ENV["TM_LINE_NUMBER"].to_i
       block_top     = lines.length + 1
       block_bottom  = 0
       search_top    = 1
       search_bottom = lines.length
       search_failed = false
EOL
    assert_equal(expected, execute(input))
    assert_output_type(:replace_selection)
  end
end