require_relative 'base_test'

require 'js/rule/no_global'

require 'parser_visitable'

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
              (function() {
                var c = 123;

                function d() {
                    
                }
              })();    
            }
          '
          
          ret = parse js 
          assert_equal 3, ret.length
          assert_equal '(var=,a,1)', ret[0].node.text
          assert_equal '(var=,b,)', ret[1].node.text
          assert_equal '(function,hello,[])', ret[2].node.text
        end
        
        def parse(js)
          parser = Parser.new js, Logger.new(STDOUT)
          parser.add_visitor XRay::JS::Rule::NoGlobal.new
          parser.parse_program
          parser.results
        end

      end
      
    end
  end
end
