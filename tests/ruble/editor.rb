class Editor  
  def selection
    # TODO Check doc to determine line numbers for offsets
    @selection ||= Selection.new(0, 0, 1, 1)
  end
  
  def selection=(sel)
    if sel.respond_to? :size
      offset = sel.first
      length = sel.last
      @selection = Selection.new(offset, length, document.line_at_offset(offset), document.line_at_offset(offset + length))
    else
      @selection = sel
    end
    
    ENV["TM_SELECTION_OFFSET"] = @selection.offset.to_s
    ENV["TM_SELECTION_LENGTH"] = @selection.length.to_s
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
  
  def offset_at_line(line)
    document.getLineInformation(line).offset
  end
  
  def caret_column
    selection.offset - offset_at_line(selection.start_line)
  end
  
  private
  def lines
    document.lines
  end
end


class Selection
  attr_reader :offset, :length, :start_line, :end_line
  
  def initialize(offset, length, start_line, end_line)
    @offset, @length = offset, length
    @start_line, @end_line = start_line, end_line
  end
  
  def ==(other_selection)
    self.offset == other_selection.offset &&
      self.length == other_selection.length &&
      self.start_line == other_selection.start_line &&
      self.end_line == other_selection.end_line
  end
end


class Document
  def initialize(str = nil)
    @string = str
  end
  
  def get(offset = nil, length = nil)
    @string ||= ''
    if offset && length
      @string[offset..(offset + length)]
    else
      @string
    end
  end
  
  def []=(offset, length, src)
    @string[offset, length] = src
  end
  
  def getLineInformation(line_number)
    line = lines[line_number - 1]
    # FIXME Need to properly iterate through @string, counting lines and offsets...
    Region.new(offset_at_line(line_number), (line || '').length)
  end
  
  def lines
    get.split(/\r?\n|\n/)
  end
  
  def offset_at_line(line)
    line = line - 1
    return 0 if line == 0
    sum = 0
    lines[0...line].each {|l| sum += l.length + 1 }
    sum
  end
  
  def line_at_offset(offset)
    get(0, offset).split(/\r?\n|\n/).length
  end
end

class Region
  attr_reader :offset, :length
  def initialize(offset, length)
    @offset, @length = offset, length
  end
end
