require 'command_testcase'
require 'toggle_single_double_string_quotes'

class ToggleStringQuotesTest < CommandTestCase
  
  def command_name
    'Toggle Single / Double String Quotes'
  end
  
  def test_toggle_double_quotes
    assert_equal("'double quotes'", execute('"double quotes"'))
    assert_output_type(:replace_selection)
  end
  
  def test_toggle_single_quotes
    assert_equal('"single quotes"', execute("'single quotes'"))
    assert_output_type(:replace_selection)
  end
end