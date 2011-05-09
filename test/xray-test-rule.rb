require 'xray-test'

class XRayRuleTest < XRayTest

    def check_css( css, param )
        xray.check_css( css, param )
    end

    def check_js( text, param)
        xray.check_js( text, param )
    end

    def check_html( text, param )
        xray.check_html( text, param )
    end
end
