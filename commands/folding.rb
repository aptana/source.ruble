require 'ruble'

with_defaults :input => :none, :output => :discard, :key_binding => "F1" do
  command 'Expand' do |cmd|
    cmd.invoke do |context|
      context.editor.editor_part.source_viewer.doOperation(org.eclipse.jface.text.source.projection.ProjectionViewer::EXPAND)
    end
  end  
  
  command 'Expand All' do |cmd|
    cmd.invoke do |context|
      context.editor.editor_part.source_viewer.doOperation(org.eclipse.jface.text.source.projection.ProjectionViewer::EXPAND_ALL)
    end
  end  
  
  command 'Collapse' do |cmd|
    cmd.invoke do |context|
      context.editor.editor_part.source_viewer.doOperation(org.eclipse.jface.text.source.projection.ProjectionViewer::COLLAPSE)
    end
  end  
  
  command 'Collapse All' do |cmd|
    cmd.invoke do |context|
      context.editor.editor_part.source_viewer.doOperation(org.eclipse.jface.text.source.projection.ProjectionViewer::COLLAPSE_ALL)
    end
  end
end
