# encoding: utf-8
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

        def test_scope_in_other_function
          js = <<-JS
          /**
           * scope test fixture
           */
          (function($){
              function test(){
                  var temp;
              }

              var _createSeperator = function(){
                   var _self = this,
                      menuEl = _self.get('menuEl');
                   temp = [a,b,c];
                   return new Node(temp).appendTo(menuEl);

               test = 123;

              //var temp2;
              temp2 = 234;
                };

          })(jQuery);
          JS

          ret = parse js 
          assert_equal [
            "禁止使用未定义的变量(或全局变量)",
            "禁止使用未定义的变量(或全局变量)"
          ], ret.map(&:message)
          assert_equal '(=,temp,[a,b,c])', ret[0].node.text
          assert_equal '(=,temp2,234)', ret[1].node.text
          
        end
        
        def parse(js)
          parse_with_rule js, XRay::JS::Rule::NoGlobalRule
        end

      end
      
    end
  end
end
