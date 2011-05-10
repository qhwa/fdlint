require 'test/unit'

class XRayTest < Test::Unit::TestCase

    def setup
        # '.xrr' means 'xray rules'
        @ray = XRay.new( :rules=>'sample_css_rule.xrr' )
    end

    def teardown
    end

    def xray
        @ray
    end

end
