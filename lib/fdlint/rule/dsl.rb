module Fdlint; module Rule

  module DSL 

    extend self

    # Public: Extend target class
    #
    # target - An String or Class object
    def helpers( target, &block )
      if target.is_a? String
        target = Object.const_get target.capitalize
      end
      target.class_eval &block
    end

    def rules_for( *syntaxes, &block )
      @syntaxes = syntaxes.map(&:intern)
      yield if block_given?
    end

    def css_rules( &block )
      rules_for( :css, &block )
    end

    def html_rules( &block )
      rules_for( :html, &block )
    end

    def js_rules( &block )
      rules_for( :js, &block )
    end

    def group( grp, &block )
      @group = grp
      yield if block_given?
    end

    def desc( description=nil )
      @desc = description
    end

    def uri( u )
      @uri = u
    end

    def check( node, &block )
      @scope = node.intern
      yield if block_given?
    end

    alias_method :review, :check

    def rule( &block )
      @syntaxes.each do |syntax|
        ::Fdlint::Rule.add syntax, @scope, {
          :block => block,
          :desc  => @desc,
          :uri   => @uri
        }
      end

      @desc = nil
      @uri  = nil
    end

  end

end; end;
