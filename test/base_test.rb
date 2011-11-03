$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'logger'
require 'test/unit'

module XRayTest
  class BaseTest < Test::Unit::TestCase
  end
end
