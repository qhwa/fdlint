require 'delegate'

module XRay
  module JS
    module Rule

      class All < SimpleDelegator

        attr_reader :rules

        def initialize(options = {})
          @rules = load_sub_rules.collect do |name|
            klass = Rule.const_get name
            klass.method(:initialize).arity >= 1 ? klass.new(options) :
                klass.new
          end

          super @rules
        end

        def load_sub_rules
          Dir.glob File.expand_path( '*.rb', File.dirname(__FILE__) ) do |file|
            require file
          end
          XRay::JS::Rule.constants.select { |c| c.to_s.end_with? 'Rule' }
        end


      end

    end
  end
end


