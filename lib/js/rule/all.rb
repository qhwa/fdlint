require 'delegate'


module XRay
  module JS
    module Rule

      class All < SimpleDelegator

        NAMES = %w( 
          semicolon
          stat_if_with_brace
          stat_if_with_muti_else
          new_object_and_new_array
          no_eval
          use_strict_equal
          nest_try_catch
          jq_check
          no_global
          file_checker 
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
