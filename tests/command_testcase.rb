require 'test/unit'

class CommandTestCase < Test::Unit::TestCase
  
  def setup
    @cmd = $commands[command_name]
    @context = CommandContext.new
  end
  
  def teardown
    @cmd = nil
    @context = nil
  end
  
  def execute(input)
    @cmd.execute(input, @context)
  end
  
  protected
  def command_name
    nil
  end
  
  def assert_output_type(type)
    assert_equal(type, @context.output)
  end
  
  # Override the method so it doesn't fail in this base class
  def default_test
  end
  
end