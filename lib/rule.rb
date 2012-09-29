require 'find'
require_relative 'js/parser'
require_relative 'html/parser'
require_relative 'css/parser'
require_relative 'helper/file_reader'
require_relative 'node'

module XRay

  module Rule

    STYLE_TYPES = [:css, :js, :html]

    def self.methods_to_keywords(klass)
      klass.instance_methods.grep( /^parse_/ ).map {|m| m[/^parse_(.*)/,1]}
    end

    RULE_PATH = File.expand_path '../rules.d', File.dirname(__FILE__)
    KEYWORDS = %w(file merge_importing merge_file)

    KEYWORDS.concat methods_to_keywords(XRay::JS::Parser)
    KEYWORDS.concat methods_to_keywords(XRay::CSS::Parser)
    KEYWORDS.concat methods_to_keywords(XRay::HTML::Parser)

    @@common_rules = []
    @@context = nil

    def syntax(*type)
      if type.empty?
        @syntax || 'common'
      else
        @syntax = type.first
      end
    end

    def common(&block)
      syntax nil
      yield if block_given?
    end

    KEYWORDS.each do |kw|
      eval <<-RUBY
      def #{kw}_rules
        @@common_rules.select {|r| r[:name].to_s.include? "#{kw}" }
      end

      def check_#{kw}( *target, &block )
        if block_given?
          self.send :"add_\#{syntax}_rule", :check_#{kw}, &block
        elsif target.size > 0
          do_check #{kw}_rules, *target
        end
      end

      RUBY

      STYLE_TYPES.each do |syn|
        eval <<-RUBY
        def #{syn}_#{kw}_rules
          #{syn}_rules.select {|r| r[:name].to_s.include? "#{kw}" }
        end

        def only_#{syn}_#{kw}_rules
          only_#{syn}_rules.select {|r| r[:name].to_s.include? "#{kw}" }
        end

        def check_#{syn}_#{kw}( *target, &block )
          if block_given?
            self.send :"add_#{syn}_rule", :check_#{syn}_#{kw}, &block
          elsif target.size > 0
            do_check #{syn}_#{kw}_rules, *target
          end
        end

        RUBY
      end
    end

    STYLE_TYPES.each do |syn|

      eval <<-RUBY

        @@#{syn}_rules = []

        def #{syn}
          syntax #{syn.inspect}
          yield if block_given?
        end

        def add_#{syn}_rule( name, &block )
          @@#{syn}_rules << { :name => name, :block => block }
        end

        def #{syn}_rules
          @@common_rules + @@#{syn}_rules
        end

        def only_#{syn}_rules
          @@#{syn}_rules
        end

        def clear_#{syn}_rules
          @@#{syn}_rules.clear
        end
      RUBY
    end

    def clear_all_rules
      @@imported.clear
      @@common_rules.clear
      STYLE_TYPES.each { |syn| send(:"clear_#{syn}_rules") }
    end

    def do_check( rules, *args )
      @@context = self
      target = args.first
      rules.inject([]) do |results, r|
        result = r[:block].call(*args)
        results << result if result
        results
      end
    end

    def context
      @@context
    end

    def method_missing( name , *args, &block )
      if cmd = cmd_name(name) and self.respond_to? cmd 
        send(cmd, name, &block )
        def_rule_cmd(cmd, name, &block) if block_given?
      else
        super
      end
    end

    def def_rule_cmd(cmd, name, &block)
      XRay::Rule.instance_eval do 
        define_method(name) do |*tar, &b|
          if tar.size > 0
            @@context = self
            block.call *tar
          else
            send cmd, name, &b
          end
        end
      end
    end
    private :def_rule_cmd

    def cmd_name(name)
      name = name.to_s
      KEYWORDS.each do |kw| 
        if name.start_with? "check_#{kw}" 
          return :"check_#{kw}"
        else 
          STYLE_TYPES.each do |s| 
            cmd = "check_#{s}_#{kw}"
            return cmd if name.start_with? cmd
          end
        end
      end
      nil
    end

    def add_common_rule( name, &block )
      @@common_rules << { :name => name , :block => block }
    end

    alias :add_rule :add_common_rule



    @@imported = []

    def import( name )
      if name.is_a? Symbol
        path = File.join(RULE_PATH, "#{name}.rule")
      else
        path = name
      end
      path = File.expand_path path
      unless imported? path
        @@imported << path
        src, enc = ::XRay::Helper::FileReader.readfile path
        instance_eval src
      end
    end

    def import_all
      Find.find( RULE_PATH ) do |rule|
        import rule if rule.end_with? '.rule'
      end
    end

    def self.import_all
      "".extend(self).import_all
    end

    def imported?(path)
      @@imported.include? path
    end

    def imported
      @@imported
    end

  end

end


if __FILE__ == $0

  extend XRay::Rule

  ## Rule DSL example
  css {
    check_file_without_min { |file|
      ['should not be min file', :error] if file =~ /-min\.css$/
    }

  }

  common {
    check_file { |file| 
      ['should use "-" instead of "_"', :warn] if file =~ /_/
    }
  }

  ## Test
  import_all

  puts file_rules
  puts css_file_rules

  puts check_file_without_min('test-min.css').inspect
  puts check_css_file('test_a-min.css').inspect
  puts check_css_value('expression(test)\0').inspect

end
