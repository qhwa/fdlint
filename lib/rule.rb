STYLE_TYPES ||= [:css, :js, :html]

module XRay

  def self.runner
    @@runner
  end

  module RuleHelper


    def method_missing(name, *arguments, &block)
      if XRay::Rule.keywords.any? { |kw| name.to_s.start_with? kw.to_s }
        XRay::Rule.add( name, syntax, &block )
      else
        super
      end
    end

    def syntax(*type)
      if type.empty?
        @syntax
      else
        @syntax = type.first
      end
    end

    STYLE_TYPES.each do |type|
      eval <<-RUBY
      def #{type}
        syntax #{type.inspect}
        yield if block_given?
      end
      RUBY
    end

  end

  module Rule

    @keywords = [
      :check_file,
      :check_css_file,
      :check_js_file,
      :check_html_file
    ]

    @rules = []

    class << self

      attr_reader :keywords, :rules

      def add( name, syntax = nil, &block )
        rules << { :syntax => syntax, :name => name , :block => block }
      end

      STYLE_TYPES.each do |syntax|
        eval <<-RUBY
          def #{syntax}_rules
            rules.select { |r| r[:syntax].nil? or r[:syntax].to_s == "#{syntax}" }
          end
        RUBY
      end

      def import( name )
        load_relative
      end

    end

  end

end

include XRay::RuleHelper


## Rule DSL example

css {
  check_file do |file|
    ['should not be min file'] if file =~ /-min\.css$/
  end
}

check_file { |file| 
  ['should use "-" instead of "_"', :warn] if file =~ /_/
}


## Test
puts XRay::Rule.css_rules
