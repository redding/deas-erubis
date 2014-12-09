# this file is automatically required when you run `assert`
# put any test helpers here

require 'pathname'

# add the root dir to the load path
ROOT = Pathname.new(File.expand_path("../..", __FILE__))
$LOAD_PATH.unshift(ROOT.to_s)

TEST_SUPPORT_PATH = ROOT.join('test/support')
TEMPLATE_ROOT = TEST_SUPPORT_PATH.join('templates')

# require pry for debugging (`binding.pry`)
require 'pry'

require 'test/support/factory'
