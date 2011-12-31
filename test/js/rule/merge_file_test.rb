# encoding: utf-8

require_relative 'base_test'

require 'js/rule/merge_file'

module XRayTest
  module JS
    module Rule
      
      class MergeFileTest < BaseTest
        
        def test_01
          js = <<END
(function(){
    ImportJavscript = {
        url:function(url){
            document.write('<script type="text/javascript" src="'+url+'"></scr'+'ipt>');
        }
    };
})();

/**
 * fdev4相关组件
 */
ImportJavscript.url('http://style.china.alibaba.com/js/lib/fdev-v4/widget/util/json2-min.js');
ImportJavscript.url('http://style.china.alibaba.com/js/lib/fdev-v4/widget/ui/core-min.js');

/**
 * 旺铺组件
 */
ImportJavscript.url('http://style.china.alibaba.com/js/app/platform/winport/module/widget/dialog-min.js');
ImportJavscript.url('http://style.china.alibaba.com/js/app/platform/winport/module/widget/ajaxlink-min.js');
ImportJavscript.url('http://style.china.alibaba.com/js/app/platform/winport/module/widget/htmleditor-min.js');
END
          
          rets = parse js, ''

        end

        def parse(js, path)
          parse_with_rule js, XRay::JS::Rule::MergeFile, :path => path 
        end

      end

    end
  end
end
