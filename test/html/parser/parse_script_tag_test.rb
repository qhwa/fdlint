require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseScriptTagTest < Test::Unit::TestCase

        include Fdlint::Parser::HTML

        def test_simple_script
          parse('<script>alert("hello");</script>') do |element|
            assert_equal Document.new(
              Element.new('script', nil, [
                TextElement.new('alert("hello");')
              ])
            ), element
          end
        end

        def test_tag_in_script
          script = %q(if(typeof isCoaseLoad=='undefined'){
                  document.write("<div></div><script type=\"text/javascript\" src=\"http://style.china.alibaba.com/js/coase/coase.js\"></scr"+"ipt>");
                  var isCoaseLoad = true;
          })
          src = %Q(<script type="text/javascript">#{script}</script>) 

          parse(src) do |e|
            assert_equal Document.new(
              Element.new('script', {:type=>"text/javascript"}, [ TextElement.new(script) ])
            ), e
          end
        end

        def test_script_in_head
          script = %q(if(typeof isCoaseLoad=='undefined'){
                  document.write("<div></div><script type=\"text/javascript\" src=\"http://style.china.alibaba.com/js/coase/coase.js\"></scr"+"ipt>");
                  var isCoaseLoad = true;
          })
          src = %Q(<head><script type="text/javascript">#{script}</script>         </head>)

          parse(src) do |e|
            assert_equal Document.new(
              Element.new('head', nil, [
                Element.new('script', {:type=>"text/javascript"}, [ TextElement.new(script) ]),
                TextElement.new('         ')
              ])
            ), e
          end
        end

        protected

          def parse(src, &block)
            Fdlint::Parser::HTML::HtmlParser.parse(src, &block)
          end

      end

    end
  end
end
