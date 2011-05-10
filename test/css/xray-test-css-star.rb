module XRayTest
    
    module CSS

        module Rule

            class Star < XRayTest::XRayRuleTest

                # 没有出现星号，应该正常处理
                def test_good_sample
                    succ, info = check_css 'a:active { color:red; }'
                    assert succ, "good example"
                    assert_nil info
                end

                # hack性质的星号，应该以notice级别提醒
                def test_good_sample_with_star
                    succ, info = check_css 'a:active { color:red; *color:blue; }'
                    assert !succ, 'should be noticed when hack used'
                    assert "1:23 hack used", info, 'star for hack is at notice level'
                end

                # 未知级别的样式文件，如果使用星号，应给出警告
                def test_bad_sample_with_unknown_source
                    succ, info = check_css '* { color:red; }'
                    assert !succ, 'should be warned when star selector used in unknow-level css'
                    assert_nil info[:fatal]
                    assert_nil info[:notice]
                    w = info[:warning]
                    assert_kind_of Array, w
                    assert_equal 1, w.size
                    assert_equal '1:1 star selector used, make sure it is global level stylesheet', w[0]
                end

                # 非页面级的样式文件可以使用星号选择符
                def test_bad_sample_from_global_stylesheet
                    succ, info = check_css( '* { color:red; }', :global_style=>true )
                    assert succ, 'should be ok when star selector used in global level css'
                    assert_nil info
                end

                # 页面级别出现带星号的选择符，以严重错误处理
                def test_bad_sample_from_page_stylesheet
                    succ, info = check_css( '* { color:red; }', :global_style=>false)
                    assert_fatal_with_star succ, info
                end

                # 页面级别出现带星号的选择符，含有其他选择符
                # 应该正确地以严重错误处理
                def test_bad_sample_with_multi_selector
                    succ, info = check_css( 'p, * { color:red; }', :global_style=>false)
                    assert_fatal_with_star succ, info
                end

                def assert_fatal_with_star( succ, info )
                    assert !succ, 'it is a fatal error using star selector in page level css'
                    assert_nil info[:warning]
                    assert_nil info[:notice]
                    f = info[:fatal]
                    assert_kind_of Array, f
                    assert_equal 1, f.size
                    assert_equal '1:1 star selector is forbidden to use in non-global level stylesheet', f[0]
                end
            end

        end
    end
end
