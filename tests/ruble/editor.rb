class Editor
  def offset_at_line(line)
    0
  end
  
  def selection
    # TODO Check doc to determine line numbers for offsets
    @selection ||= Selection.new(0, 0, 1, 1)
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
end


class Selection
  attr_reader :offset, :length, :start_line, :end_line
  
  def initialize(offset, length, start_line, end_line)
    @offset, @length = offset, length
    @start_line, @end_line = start_line, end_line
  end
end


class Document
  def initialize(str)
    @string = str
  end
  
  def get
    @string ||= ''
  end
  
  def []=(offset, length, src)
    @string[offset, length] = src
  end
end

