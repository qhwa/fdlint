#!/usr/bin/env ruby
require 'optparse'
require 'find'
require 'logger'
require 'fdlint/helper/logger'
require 'fdlint/printer'
require 'fdlint/printer/vim_printer'
require 'fdlint/printer/nocolor_printer'
require 'fdlint/printer/console_printer'

module Fdlint

  module CLI

    def self.run( options )
      Runner.new( options ).run
    end

    def self.list_rules( options )
      Runner.new( options ).list_rules
    end

    class Runner

      include Fdlint::Helper::Logger

      attr_reader :options, :files

      def initialize( options={} )

        @options  = options
        @files    = options[:files]
        # 默认不检查已经被压缩的文件
        @checkmin = options[:checkmin]

        # Windows 下默认是ANSI编码
        # 我们需要使用 UTF-8 编码输出
        IO.popen "chcp 65001" if ENV['OS'] =~ /windows/i

        $logger = Logger.new(STDOUT).tap do |l|
          l.level = options[:debug] ? Logger::DEBUG : Logger::FATAL
        end
      end

      def run

        trap("SIGINT") { puts "\nGoodbye!"; exit! }

        if text = @options[:text]
          validate_content
        elsif !@files.empty?
          validate_files
        end
      end

      def list_rules
        ::Fdlint::Rule.rules.each do |syntax, rules|
          puts "----> #{syntax} (#{rules.size})\n\n"
          rules.each do |rule|
            print " " * 6
            print rule
            print "\n"
          end
          print "\n"
        end
      end

      protected

        def validate_content
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
            unless File.directory? f
              if need_check? f
                validate_file f
              end
            end
          end
        end

        def validate_file( path )
          printer.pre_validate path
          ::Fdlint::Validator.new( path, opt_for_validator ).validate do |file, source, results|
            printer.print( file, source, results )
          end
          printer.post_validate path
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

        def need_check? path
          if path =~ /([\.-_])min\.(css|js|html?)$/i && !@checkmin
            info { "ignore minified file '#{path}'" }
            return false
          end

          reg = case options[:syntax]
                when :js, :css
                  /\.#{options[:syntax]}$/i
                when :html
                  /\.html?$/i
                else
                  /\.(js|css|html?)$/i
                end

          path =~ reg
        end

        def opt_for_validator
          {
            :syntax     => options[:syntax],
            :text       => options[:text],
            :log_level  => options[:log_level]
          }
        end

    end
  end
end
