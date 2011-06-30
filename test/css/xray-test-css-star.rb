# encoding: utf-8

require_relative '../helper'

require 'css/scanner'

module XRayTest
    
    module CSS

        module Rule

            class Star < Test::Unit::TestCase

                include XRay

                def check_css text
                    XRay::CSS.scan text
                end

                 
                def test_good_sample
                    result = check_css 'a:active { color:red; }'
                    assert_equal [], result, "没有出现星号，应该正常处理"
                end

                # 
                def test_good_sample_with_star
                    text = 'a:active { color:red; *color:blue; }'
                    result = check_css( text )

                    expect = XRay::ScanLogEntry.new
                    expect.file_name    = nil
                    expect.row          = 0
                    expect.col          = text.index( '*' )
                    expect.level        = :info

                    assert_equal [ expect ], result, 'hack性质的星号，应该以notice级别提醒'
                end

            end
        end
    end
end
