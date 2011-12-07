# encoding: utf-8

require_relative '../../helper'
require 'html/rule/check_tag_rule'

module XRayTest
  module HTML
    module Rule
      
      class CheckHTMLTemplateTest < Test::Unit::TestCase

        include XRay::HTML

        def setup
          @rule = XRay::HTML::Rule::CheckTagRule.new
          @head = %Q(<head>
                  <meta charset="gbk"/>
                  <title>阿里巴巴</title>
                  <mea name="description" content="阿里巴巴批发大市场"/>
                  <meta name="keywords" content="阿里巴巴,采购批发,1688,行业门户,网上贸易,b2b,电子商务"/>
                  <link href="产品线merge.css" rel="stylesheet"/>
                  <link href="页面merge.css" rel="stylesheet"/>
                  <script src="产品线merge.js"></script>
                  <base target="_blank"/>
              </head>)
          @doc = %Q(<div id="doc">
                      <div id="alibar">alibar</div>
                      <div id="header" class="w952">header</div>
                      <div id="content" class="w952">content</div>
                      <div id="footer">footer</div>
                  </div>)
          @body = %Q(<body>
                  #{@doc}
                  <script src="页面merge.js"></script>
              </body>)
          @html = %Q(<html lang="zh-CN">
              #{@head}
              #{@body}
          </html>)
        end

        def test_check_right_tag
          tag = parse(@html)
          assert_equal [], @rule.check_tag(tag)
        end

        def test_check_missing_desc
          tag = parse(@head.sub(/<meta name="description".*?\/>/m, ''))
          assert_equal [["新页面按库中的HTML基本结构模板书写基本页面结构", :warn]], @rule.check_tag(tag)
        end

        def test_check_missing_keywords
          tag = parse(@head.sub(/<meta name="keywords".*?\/>/m, ''))
          assert_equal [["新页面按库中的HTML基本结构模板书写基本页面结构", :warn]], @rule.check_tag(tag)
        end

        def test_check_missing_doc
          tag = parse(@body.sub(/<div id="doc"/m, '<div id="_doc"'))
          assert_equal [["新页面按库中的HTML基本结构模板书写基本页面结构", :warn]], @rule.check_tag(tag)
        end

        def test_check_missing_alibar
          tag = parse(@body.sub(/<div id="alibar"/m, '<div id="_alibar"'))
          assert_equal [], @rule.check_tag(tag)

          tag = parse(@doc.sub(/<div id="alibar"/m, '<div id="_alibar"'))
          assert_equal [["新页面按库中的HTML基本结构模板书写基本页面结构", :warn]], @rule.check_tag(tag)
        end

        def test_check_missing_content
          tag = parse(@body.sub(/<div id="content"/m, '<div id="_content"'))
          assert_equal [], @rule.check_tag(tag)

          tag = parse(@doc.sub(/<div id="content"/m, '<div id="_content"'))
          assert_equal [["新页面按库中的HTML基本结构模板书写基本页面结构", :warn]], @rule.check_tag(tag)
        end

        def test_check_missing_footer
          tag = parse(@body.sub(/<div id="footer"/m, '<div id="_footer"'))
          assert_equal [], @rule.check_tag(tag)

          tag = parse(@doc.sub(/<div id="footer"/m, '<div id="_footer"'))
          assert_equal [["新页面按库中的HTML基本结构模板书写基本页面结构", :warn]], @rule.check_tag(tag)
        end

        def test_check_missing_header
          tag = parse(@body.sub(/<div id="header"/m, '<div id="_header"'))
          assert_equal [], @rule.check_tag(tag)

          tag = parse(@doc.sub(/<div id="header"/m, '<div id="_header"'))
          assert_equal [["新页面按库中的HTML基本结构模板书写基本页面结构", :warn]], @rule.check_tag(tag)
        end

        private
        def parse(src)
          XRay::HTML::Parser.parse(src)
        end

      end

    end
  end
end
