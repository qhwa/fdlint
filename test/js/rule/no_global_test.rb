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
        
        def test_fail
          jses = []

          jses << '
            var a;
            a++;
            function hello() {
            }
          '

          jses << '
            1 + 1
            function hello() {
                
            }
          '

          jses.each do |js|
            ret = parse js 
          end
        end

        def test_ok
          jses = []

          jses << '
            (function() {
              var a;
              a++
              function hello() {
                  
              }
            })();
          '

          jses.each do |js|

          end
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
