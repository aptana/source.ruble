require 'ruble'

# Toggles folding at a specific level of nesting
def toggle_folding(editor, level)
  source_viewer = editor.editor_part.source_viewer
  model = source_viewer.projection_annotation_model
  annotations = []
  positions = []
  iter = model.annotation_iterator
  while iter.hasNext()
    a = iter.next
    annotations << a
    positions << model.getPosition(a)
  end  
  
  to_toggle = []
  # iterate over positions
  # check if position is included by x other positions?
  annotations.each_with_index do |a, index|
    count = 0
    position = positions[index]
    positions.each {|p| count += 1 if p != position and p.includes(position.offset) }
    to_toggle << a if count == level - 1
  end

  to_toggle.each {|t| model.toggleExpansionState(t) }
end

# Toggle Folding levels explicitly
with_defaults :input => :none, :output => :discard, :key_binding => "OPTION+COMMAND+0" do
  command t(:all_levels) do |cmd|
    cmd.invoke do |context|
      # Toggle all levels
      context.editor.editor_part.source_viewer.doOperation(org.eclipse.jface.text.source.projection.ProjectionViewer::COLLAPSE_ALL)
    end
  end  
  
  1.upto(9).each do |level|
    command level.to_s do |cmd|
      cmd.key_binding = "OPTION+COMMAND+" + level.to_s
      cmd.invoke {|context| toggle_folding(context.editor, level) }
    end
  end  
end
