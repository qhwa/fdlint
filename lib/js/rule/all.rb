require 'delegate'

module XRay
  module JS
    module Rule

      class All < SimpleDelegator

        Dir.glob File.join(File.expand_path(File.dirname(__FILE__)), '*.rb') do |file|
          if file != File.expand_path(__FILE__)
            require file
          end
        end

        RULES = XRay::JS::Rule.constants.select { |c| c.to_s.end_with? 'Rule' }

        attr_reader :rules

        def initialize(options = {})
          @rules = RULES.collect do |name|
            klass = Rule.const_get name
            klass.method(:initialize).arity >= 1 ? klass.new(options) :
                klass.new
          end

          super @rules
        end



      end

    end
  end
end


