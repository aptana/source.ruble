require 'command_testcase'
require 'insert_source_header'

class InsertSourceHeaderTest < CommandTestCase
  
  def command_name
    'Insert Comment Header'
  end
  
  def teardown
    super
    ENV['TM_COMMENT_START'] = nil
    ENV['TM_FULLNAME'] = nil
    ENV['TM_ORGANIZATION_NAME'] = nil
  end
  
  def test_insert_source_header
    ENV['TM_COMMENT_START'] = "# "
    year = Time.now.year
    date = Time.now.strftime("%Y-%m-%d").chomp
    username = "John Doe"
    organization = "Acme, Inc"
    ENV['TM_FULLNAME'] = username
    ENV['TM_ORGANIZATION_NAME'] = organization
    expected = "# \n#  ${1:<file>}\n#  ${2:<project>}\n#  \n#  Created by #{username} on #{date}.\n#  Copyright #{year} #{organization}. All rights reserved.\n# \n$0"
    assert_equal(expected, execute(nil))
    assert_output_type(:insert_as_snippet)
  end
end