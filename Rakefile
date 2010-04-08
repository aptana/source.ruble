require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Rake::TestTask.new do |t|
  t.libs << ["tests", "commands"]
  t.test_files = FileList['tests/test*.rb']
end
