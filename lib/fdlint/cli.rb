#!/usr/bin/env ruby
require 'optparse'
require 'find'
require 'logger'


module Fdlint

  module CLI

    def self.run
      Runner.new( Options.parse ARGV ).run
    end

    class Runner

      attr_reader :options, :files

      def initialize( options={} )
        @options = options
        @files   = options[:files]
      end

      def run
        # Windows 下默认是ANSI编码
        # 我们需要使用 UTF-8 编码输出
        IO.popen "chcp 65001" if ENV['OS'] =~ /windows/i

        $logger = Logger.new(STDOUT).tap do |l|
          l.level = options[:debug] ? Logger::DEBUG : Logger::FATAL
        end

        trap("SIGINT") { puts "\nGoodbye!"; exit! }

        if text = @options[:text]
          validate_content
        elsif !@files.empty?
          validate_files
        end
      end

      protected

        def validate_content
          opt_for_validator = {
            :code_type  => options[:code_type],
            :text       => options[:text]
          }
          ::Fdlint::Validator.new( nil, opt_for_validator ).validate do |file, source, results|
            printer.print( file, source, results )
          end
        end

        def validate_files
          files.each do |file|
            validate_path file do |file, source, results|
              printer.print( file, source, results )
            end
          end
        end

        def validate_path( path, &block )
          if File.directory? path
            validate_directory path
          else
            validate_file path
          end
        end

        def validate_directory( dir )
          Find.find dir do |f|
            validate_file f unless File.directory? f
          end
        end

        def validate_file( path )
          ::Fdlint::Validator.new( path ).validate do |file, source, results|
            printer.print( file, source, results )
          end
        end

      private

        def printer
          @printer ||= printer_for( @options[:format] )
        end

        def printer_for format
          mapping = {
            :console => ::Fdlint::Printer::ConsolePrinter.new,
            :nocolor => ::Fdlint::Printer::NoColorPrinter.new,
            :vim     => ::Fdlint::Printer::VimPrinter.new
          }.tap {|hash| hash.default = hash[:console] }
          mapping[format]
        end

    end

    require 'fdlint/printer/vim_printer'
    require 'fdlint/printer/nocolor_printer'
    require 'fdlint/printer/console_printer'

    class Options

      DEFAULT = {
        :encoding   => 'gb2312',
        :colorful   => true,
        :type       => nil,
        :check_min  => false,
        :format     => :console
      }

      class << self

        def parse( args )

          options = DEFAULT.dup

          opts = OptionParser.new do |opts|
            opts.banner = "Usage: fdlint"
            %w(css js html).each do |type|
              opts.on("--#{type}", "check #{type} files only") do
                options[:code_type] = type.intern
              end
            end
            opts.on("--charset set", "-c", "file charset") do |enc|
              options[:encoding] = enc
            end
            opts.on("--debug", "-d", "print debug info") do
              options[:debug] = true
            end
            opts.on("--list", "-l", "list results without source, the same as '--format=nocolor'") do
              options[:format] = :nocolor
            end
            opts.on("--checkmin", "-m", "check minified files too. (e.g. *-min.js; *-min.css)") do
              options[:check_min] = true
            end
            opts.on("--format [type]", [:console, :nocolor, :vim], "output format. Can be 'vim', 'console' or 'nocolor'. Default is 'console'") do |f|
              options[:format] = f.intern
            end
            opts.on("--level [log_level]", [:warn, :error, :fatal], "determine the log level. Can be 'warn', 'error' or 'fatal'") do |level|
              options[:log_level] = level
            end
          end

          files = []

          begin
            rest = opts.parse! args
            files.concat rest

            if files.empty?
              unless $stdin.tty?
                str = ARGF.read
                options[:text] = str
              else
                raise ArgumentError.new("") 
              end
            else
              options[:files] = files
            end

          rescue => e
            puts e.message.capitalize + "\n\n"
            puts opts
            exit 1
          end

          options

        end


      end

    end
  end
end
