# encoding: utf-8
require_relative 'base_test'

module FdlintTest
  module JS
    module Rule
    
      class NoGlobalTest < BaseTest

        should_with_result [:error, '禁止使用未定义的变量(或全局变量)'] do
          [
            %Q{ var a = 1; },
            %Q{ (function(k) {
                  var c = 123;

                  function d(j) {
                    a = 1000;
                    z = 200; 
                    k = 300;
                    j = 400
                  }
                })()
            }, <<-SRC
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

                       //global var
                       temp = [a,b,c];
                       return new Node(temp).appendTo(menuEl);
                  };
              })(jQuery);
            SRC
          ]
        end

      end
      
    end
  end
end
