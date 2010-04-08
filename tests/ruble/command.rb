module Ruble
  class Command
    def initialize(name)
      @name = name
      @hash = {}
      @invoke = Ruble::Invoke.new
    end
    
    def invoke(&block)
      if block_given?
        @invoke.all = block
      else
        @invoke
      end
    end
    
    def invoke=(invokeString)
      @invoke.all = invokeString if invokeString
    end
      
    def method_missing(symbol, *args)
      if symbol.to_s.end_with? "="
        @hash[symbol.to_s[0..-2]] = *args
      else
        @hash[symbol.to_s]
      end
    end
    
    def execute(input, context = CommandContext.new)
      context.output = output.first if context
      ENV["TM_BUNDLE_SUPPORT"] = File.join(File.dirname(__FILE__), "..", "..", "lib")
      result = nil
  
      if invoke.is_block?
        require 'stringio'
        
        $stdin = StringIO.new(input || "")
        $stdout = StringIO.new
        begin
          result = invoke.active.call(context)
          result ||= $stdout.string
        rescue SystemExit => e
          # TODO Save the exit code?
          result ||= $stdout.string
          result = context.forced_output if context.forced_output
        ensure
          $stdin = STDIN
          $stdout = STDOUT
        end
      else
        # This command has a shell script for the invoke, so we need to run that
        # Create tmpfile with the contents of cmd.invoke
        require 'tempfile'
        
        file = Tempfile.new("ascii")
        File.open(file.path, 'w') {|f| f.puts(invoke.active) }
        result = IO.popen("/bin/bash -l \"#{file.path}\"", 'r+') do |io|
          if input
            io.puts input
            io.close_write
          end
          io.read
        end
      end
      result
    end   
  end
end

$commands = {}
def command(name, &block)
   command = Ruble::Command.new(name)
   block.call(command) if block_given?
   $commands[name] = command
end