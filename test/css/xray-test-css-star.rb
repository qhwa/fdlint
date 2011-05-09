class XRayTest_CSS_Star < XRayRuleTest

    def test_good_sample
        succ, info = test_css 'a:active { color:red; }'
        assert succ
        assert_nil info
    end

    def test_good_sample_with_star
        succ, info = test_css 'a:active { color:red; *color:blue; }'
        assert succ
        assert_nil info
    end

    def test_bad_sample_with_unknown_source
        succ, info = test_css '* { color:red; }'
        assert !succ
        assert_nil info[:fatal]
        assert_nil info[:notice]
        w = info[:warning]
        assert_kind_of Array, w
        assert_equal 1, w.size
        assert_equal '0:0 star selector used, make sure it is global level stylesheet', w[0]
    end

    def test_bad_sample_from_global_stylesheet
        succ, info = test_css( '* { color:red; }', :global_style=>true )
        assert succ
        assert_nil info
    end

    def test_bad_sample_from_page_stylesheet
        succ, info = test_css( '* { color:red; }', :global_style=>false)
        assert_fatal_with_star succ, info
    end

    def test_bad_sample_with_multi_selector
        succ, info = test_css( 'p, * { color:red; }', :global_style=>false)
        assert_fatal_with_star succ, info
    end

    def assert_fatal_with_star( succ, info )
        assert !succ
        assert_nil info[:warning]
        assert_nil info[:notice]
        f = info[:fatal]
        assert_kind_of Array, f
        assert_equal 1, f.size
        assert_equal '0:0 star selector is forbidden to use in non-global level stylesheet', f[0]
    end

end
