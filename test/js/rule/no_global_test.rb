require_relative 'base_test'

require 'js/rule/no_global'

module XRayTest
  module JS
    module Rule
    
      class NoGlobalTest < BaseTest
        
        class Parser < XRay::JS::Parser
          include XRay::ParserVisitable 
        end
        
        def test_main
          js = '
            var a = 1;
            a++;
            function hello() {
            }
            if (a < 100) {
              var b;
              (function(k) {
                var c = 123;

                function d(j) {
                  a = 1000;
                  z = 200; 
                  k = 300;
                  j = 400
                }
              })();    
            }
          '
          
          ret = parse js 
          assert_equal 4, ret.length
          assert_equal '(var,[(var=,a,1)],)', ret[0].node.text
          assert_equal 'hello', ret[1].node.text
          assert_equal '(var,[(var=,b,)],)', ret[2].node.text
          assert_equal '(=,z,200)', ret[3].node.text
        end
        
        def parse(js)
          parse_with_rule js, XRay::JS::Rule::NoGlobal
        end

      end
      
    end
  end
end
