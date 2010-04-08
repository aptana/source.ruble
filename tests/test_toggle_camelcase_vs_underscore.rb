require 'command_testcase'
require 'toggle_camelcase_vs_underscore'

class ToggleCamelcaseVsUnderscoreTest < CommandTestCase
  
  def command_name
    'Toggle camelCase / snake_case / PascalCase'
  end
  
  def test_camel_to_pascal
    assert_equal("CamelCase", execute('camelCase'))
    assert_output_type(:replace_selection)
  end
  
  def test_pascal_to_snake
    assert_equal('camel_case', execute("CamelCase"))
    assert_output_type(:replace_selection)
  end
  
  def test_snake_to_camel
    assert_equal('camelCase', execute("camel_case"))
    assert_output_type(:replace_selection)
  end
  
  def test_empty_input
    assert_equal('', execute(''))
    assert_output_type(:discard)
  end
  
  def test_spaces
    assert_equal("   ", execute('   '))
    assert_output_type(:replace_selection)
  end
end