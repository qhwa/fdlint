# encoding: utf-8

require_relative 'base_test'

require 'js/rule/file_checker'

module XRayTest
  module JS
    module Rule
      
      class FileCheckerTest < BaseTest
          
        def setup
          @checker = XRay::JS::Rule::FileChecker.new 
        end

        def test_merge_file?
          assert @checker.merge_file?('abc-merge.js')
          assert @checker.merge_file?('abc-merge-12345.js')
          assert @checker.merge_file?('abc-merge12345.js')
          
          assert !@checker.merge_file?('abc-merge.css')
          assert !@checker.merge_file?('abc-merge.jss')
          assert !@checker.merge_file?('-merge.js')
          assert !@checker.merge_file?('abc-mergeabc.js')
          assert !@checker.merge_file?('abc-merge-.js')
        end

        def test_min_file?
          assert @checker.min_file?('abc-min.js') 
          
          assert !@checker.min_file?('abc-min.jss') 
          assert !@checker.min_file?('-min.js') 
          assert !@checker.min_file?('abc-min1.js') 
        end

        def test_grep_import_js_path
          pathes = @checker.grep_import_js_path fixture_01
          assert_equal 6, pathes.length
          assert_equal %w(
            http://style.china.alibaba.com/js/common/aliclick.js
            http://style.china.alibaba.com/js/detail/xpclick.js
            http://style.china.alibaba.com/js/lib/fdev-v4/widget/util/debug-min.js
            http://style.china.alibaba.com/js/lib/fdev-v4/widget/web/alitalk-min.js
            http://style.china.alibaba.com/js/lib/fdev-v4/widget/web/sweet-min.js
            http://style.china.alibaba.com/js/lib/fdev-v4/widget/web/sweet-min.js
          ), pathes.collect { |path| path[:url] }
        end

        def test_check_one_line_one_import
          pathes = @checker.grep_import_js_path fixture_01
          ret = @checker.check_one_line_one_import pathes
          assert_equal 1, ret.length
        end

        def test_check_strict_import_js
          pathes = @checker.grep_import_js_path fixture_01
          ret = @checker.check_strict_import_js pathes
          assert_equal 2, ret.length
        end

        def test_has_doc_comment
          js = '
            /**
             * 功能文件头必须要有文档注释
             * 现在没有对doc格式进行规范
             * 所以暂时不做文档注释内容检查
             * 只检则有注释
             */

            i++;
          '
          assert @checker.has_doc_comment?(js)
          
          js = '
            i++;
          '
          assert !@checker.has_doc_comment?(js)

          js = '
            /*
             * 多行注释不属于文档注释
             * 文档注释需要以/*开头
             */
          '
          assert !@checker.has_doc_comment?(js)
        end

        def test_check_import_js_scope
          #not complete
        end

        def test_check_import_js_exist_and_min
          # not complete
        end

        def fixture_01
<<END
(function(){
    ImportJavscript = {
        url:function(url){
            document.write('<script type="text/javascript" src="'+url+'"></scr'+'ipt>');
        }
    };
})();

/**
 * 打点依赖库
 */
ImportJavscript.url('http://style.china.alibaba.com/js/common/aliclick.js');
ImportJavscript.url(http://style.china.alibaba.com/js/detail/xpclick.js);

/**
 * 旺铺基础JS
 */
ImportJavscript.url("http://style.china.alibaba.com/js/lib/fdev-v4/widget/util/debug-min.js"); ImportJavscript.url("http://style.china.alibaba.com/js/lib/fdev-v4/widget/web/alitalk-min.js");
ImportJavscript.url( 'http://style.china.alibaba.com/js/lib/fdev-v4/widget/web/sweet-min.js' ) ;
ImportJavscript.url('http://style.china.alibaba.com/js/lib/fdev-v4/widget/web/sweet-min.js')
END
        end

      end

    end
  end
end

