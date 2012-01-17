require 'delegate'


module XRay
  module JS
    module Rule

      class All < SimpleDelegator

        NAMES = %w( 
          checklist
          no_global
        )

        NAMES.each { |name| require_relative name }

        attr_reader :rules

        def initialize(options = {})
          @rules = NAMES.collect do |name|
            name = name.gsub(/_(\w)/) { |m| $1.upcase }
            name = name[0..0].upcase + name[1..-1]
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
