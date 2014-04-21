# encoding: utf-8

#require 'profile'

require 'logger'

require 'fdlint/validator'
require 'fdlint/validator/css'
require 'fdlint/validator/html'
require 'fdlint/validator/js'

module Fdlint

  class Runner
    
    attr_reader :source, :rules
  
    def initialize(opt={})
      @opt = {
        :encoding   => 'utf-8',
        :debug      => false,
        :log_level  => :warn
      }.merge opt

      import_rules

      if @opt[:debug]
        @logger       = Logger.new(STDOUT)
        @logger.level = Logger::INFO
      end

    end

    def import_rules
      @rules = Rule.import_all
    end

    def validate_css( path=nil, opt={} )
      validate( path, opt.merge!( :code_type => :css ) )
    end

    def validate_html( path=nil, opt={} )
      validate( path, opt.merge!( :code_type => :html ) )
    end

    def validate_js( path=nil, opt={} )
      validate( path, opt.merge!( :code_type => :js ) )
    end

    def validate( path=nil, opt={} )
      @source  = opt[:content] || read_file( path )

      opt[:code_type] ||= Fdlint::Helper::CodeType.guess( path, @source )

      Fdlint::Validator::CSS.new.validate( path, opt ) do |file, source, results|
        @file, @source, @results = file, source, results
        print_results
      end
    end

    def print_results
    end

  end
end
