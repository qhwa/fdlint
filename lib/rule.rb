require 'find'
require_relative 'helper/file_reader'
require_relative 'node'

STYLE_TYPES ||= [:css, :js, :html]

module XRay

  module Rule

    RULE_PATH = 'rules.d'
    KEYWORDS = %w(file selector ruleset declaration property value
      dtd tag doc
    )

    @@common_rules = []

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
          do_check *target, #{kw}_rules
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
            do_check *target, #{syn}_#{kw}_rules
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

    def do_check( *args , rules )
      target = args.first
      if target && target.is_a?(XRay::Node)
        target.context = self 
      end
      rules.inject([]) do |results, r|
        result = r[:block].call(*args)
        results << result if result
        results
      end
    end

    def method_missing( name , *args, &block )
      if cmd = cmd_name(name) and self.respond_to? cmd 
        send(cmd, name, &block )
        if block_given?
          XRay::Rule.instance_eval do 
            define_method(name) do |*tar, &b|
              if tar.size > 0
                block.call(*tar)
              else
                send(cmd, name, &b )
              end
            end
          end
        end
      else
        super
      end
    end

    def cmd_name(name)
      name = name.to_s
      KEYWORDS.each do |kw| 
        if name.start_with? "check_#{kw}" 
          return :"check_#{kw}"
        else 
          STYLE_TYPES.each do |s| 
            return :"check_#{s}_#{kw}" if name.start_with? "check_#{s}_#{kw}"
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

#include XRay::RuleHelper
#


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
