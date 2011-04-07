class Editor
  def offset_at_line(line)
    line = line - 1
    return 0 if line == 0
    sum = 0
    lines[0...line].each {|l| sum += l.length + 1 }
    sum
  end
  
  def selection
    # TODO Check doc to determine line numbers for offsets
    @selection ||= Selection.new(0, 0, 1, 1)
  end
  
  def selection=(sel)
    @selection = sel
    
    ENV["TM_SELECTION_OFFSET"] = sel.offset.to_s
    ENV["TM_SELECTION_LENGTH"] = sel.length.to_s
  end
  
  def []=(offset, length, src)
    document[offset, length] = src
  end
  
  def document
    @document ||= Document.new
  end
  
  def document=(str)
    @document = Document.new(str)
  end
  
  def caret_line
    @selection.start_line
  end
  
  def current_line
    lines[caret_line - 1]
  end
  
  def line(line_num)
    lines[line_num - 1]
  end
  
  private
  def lines
    @document.get.split(/\r?\n|\n/)
  end
end


class Selection
  attr_reader :offset, :length, :start_line, :end_line
  
  def initialize(offset, length, start_line, end_line)
    @offset, @length = offset, length
    @start_line, @end_line = start_line, end_line
  end
end


class Document
  def initialize(str = nil)
    @string = str
  end
  
  def get
    @string ||= ''
  end
  
  def []=(offset, length, src)
    @string[offset, length] = src
  end
end

