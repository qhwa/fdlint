$LOAD_PATH << '.'
require 'test/unit'
require 'cls-xray-test'
require 'cls-xray-test-rule'
require 'css/xray-test-css-star'

class Test_AllCSSTest
   def self.suite
     suite = Test::Unit::TestSuite.new
     suite << XRayTest_CSS_Star.new
     return suite
   end
end

