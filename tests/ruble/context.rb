class CommandContext
  attr_accessor :output, :forced_output
  
  def initialize
    @output = :undefined
    @hash = {}
  end
  
  def exit_discard
    @output = :discard
    exit(1)
  end
  
  def exit_show_tool_tip(message)
    @output = :show_as_tooltip
    # FIXME Need to set the output of the command here!
    @forced_output = message
    exit(1)
  end
  
  def editor
    @editor ||= Editor.new
  end
  
  def [](key)
    @hash[key]
  end
  
  def []=(key, value)
    @hash[key] = value
  end
end