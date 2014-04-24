require_relative '../../helper'

module FdlintTest
  module HTML
    module Parser

      class ParseWithStyleTagTest < Test::Unit::TestCase
        
        include Fdlint::Parser::HTML

        def test_parse_style
          text = %q(<style id=gstyle>body{margin:0;overflow-y:scroll}#gog{padding:3px 8px 0}td{line-height:.8em}.gac_m td{line-height:17px}form{margin-top:10px;margin-bottom:20px}body,td,a,p,.h{font-family:arial,sans-serif}.h{color:#36c}.q{color:#00c}.ts td{padding:0}.ts{border-collapse:collapse}em{color:#c03;font-style:normal;font-weight:normal}a em{text-decoration:underline}.lst{height:25px;width:496px}#lst-ib:hover{border-color:#a0a0a0 #b9b9b9 #b9b9b9 #b9b9b9!important;}#lst-ib.lst-d-f,#lst-ib:hover.lst-d-f{border-color:#4d90fe!important;}.gsfi,.lst{font:18px arial,sans-serif}.gsfs{font:17px arial,sans-serif}.ds{display:-moz-inline-box;display:inline-block;margin:3px 0 4px;margin-left:4px}.jhp input[type="submit"],.gssb_c input,.gac_bt input{background-image:-webkit-gradient(linear,left top,left bottom,from(#f5f5f5),to(#f1f1f1));background-image:-webkit-linear-gradient(top,#f5f5f5,#f1f1f1);-webkit-border-radius:2px;-webkit-user-select:none;background-color:#f5f5f5;background-image:linear-gradient(top,#f5f5f5,#f1f1f1);background-image:-o-linear-gradient(top,#f5f5f5,#f1f1f1);border:1px solid #dcdcdc;border:1px solid rgba(0, 0, 0, 0.1);border-radius:2px;color:#666;cursor:pointer;font-size:11px;font-weight:bold;height:29px;line-height:27px;margin:11px 6px;min-width:54px;padding:0 8px;text-align:center}.jhp input[type="submit"]:hover,.gssb_c input:hover,.gac_bt input:hover{background-image:-webkit-gradient(linear,left top,left bottom,from(#f8f8f8),to(#f1f1f1));background-image:-webkit-linear-gradient(top,#f8f8f8,#f1f1f1);-webkit-box-shadow:0 1px 1px rgba(0,0,0,0.1);background-color:#f8f8f8;background-image:linear-gradient(top,#f8f8f8,#f1f1f1);background-image:-o-linear-gradient(top,#f8f8f8,#f1f1f1);border:1px solid #c6c6c6;box-shadow:0 1px 1px rgba(0,0,0,0.1);color:#333}.jhp input[type="submit"]:focus,.gssb_c input:focus,.gac_bt input:focus{border:1px solid #4d90fe;outline:none}.gssb_c input,.gac_bt input{margin:6px;}input{font-family:inherit}.lsb:active,.gac_sb:active{background:-webkit-gradient(linear,left top,left bottom,from(#ccc),to(#ddd))}a.gb1,a.gb2,a.gb3,a.gb4{color:#11c !important}#gog{background:#fff}#gbar,#guser{font-size:13px;padding-top:1px !important}#gbar{float:left;height:22px}#guser{padding-bottom:7px !important;text-align:right}.gbh,.gbd{border-top:1px solid #c9d7f1;font-size:1px}.gbh{height:0;position:absolute;top:24px;width:100%}#gbs,.gbm{background:#fff;left:0;position:absolute;text-align:left;visibility:hidden;z-index:1000}.gbm{border:1px solid;border-color:#c9d7f1 #36c #36c #a2bae7;z-index:1001}.gb1{margin-right:.5em}.gb1,.gb3{zoom:1}.gb2{display:block;padding:.2em .5em}.gb2,.gb3{text-decoration:none !important;border-bottom:none}a.gb1,a.gb4{text-decoration:underline !important}a.gb1,a.gb2,a.gb3,a.gb4{color:#00c !important}a.gb2:hover{background:#36c;color:#fff !important}#gbar .gbz0l{color:#000 !important;cursor:default;font-weight:bold;text-decoration:none !important}body{background:#fff;color:black}input{-moz-box-sizing:content-box}a{color:#11c;text-decoration:none}a:hover,a:active{text-decoration:underline}.fl a{color:#36c}a:visited{color:#551a8b}a.gb1,a.gb4{text-decoration:underline}a.gb3:hover{text-decoration:none}#ghead a.gb2:hover{color:#fff!important}.sblc{padding-top:5px}.sblc a{display:block;margin:2px 0;margin-left:13px;font-size:11px;}.lsbb{height:30px;display:block}.ftl,#footer a{color:#2200c1;}#fll a, .ftl{margin: 0 8px;}#fll{display:inline}.lsb{border:none;color:#000;cursor:pointer;height:30px;margin:0;outline:0;font:15px arial,sans-serif;vertical-align:top}.lsb:active{background:#ccc}.lst:focus{outline:none}#addlang a{padding:0 3px}.gac_v div{display:none}.gac_v .gac_v2,.gac_bt{display:block!important}#footer{color:#666;font-size:10pt;min-height:49px;min-width:780px;position:relative}#footer #cp-sol{margin-right:52px;}</style>)
          HtmlParser.parse(text) do |e|
            assert_equal text, e.outer_html
          end
        end

      end

    end
  end
end
