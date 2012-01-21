#!/usr/bin/env ruby
require 'optparse'
require 'find'
require_relative 'runner'
require_relative 'printer/vim_printer'
require_relative 'printer/console_printer'
require_relative 'printer/nocolor_printer'

module XRay

  Version = "0.1"

  class CMDOptions

    def self.parse( args )
      files = []
      options = {
        :encoding   => 'gb2312',
        :colorful   => true,
        :type       => nil,
        :check_min  => false,
        :format     => :console
      }

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: xray"
        %w(css js html).each do |type|
          opts.on("--#{type}", "check #{type} files only") do
            options[:type] = type
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
      end

      begin
        rest = opts.parse! args
        files.concat rest

        if $stdin.tty?
          raise ArgumentError.new("") if files.empty?
        else
          str = ARGF.read
          options[:text] = str
        end

      rescue => e
        puts e.message.capitalize + "\n\n"
        puts opts
        exit 1
      end
      [options, files]

    end

  end

  class CMDRunner

    def self.run
        self.new.run
    end

    def run
      options, files = XRay::CMDOptions.parse ARGV
      @core_runner = XRay::Runner.new(options)

      unless files.empty?
        files.each do |file|
          check_file file, options
        end
      else
        method = options[:type] ? :"check_#{options[:type]}" : :check
        print @core_runner.send(method, options[:text]), options
      end
    end

    private
    def check_file( file, opt)

      if File.directory? file
        Find.find(file) do |f|
          check_file(f, opt) unless File.directory? f
        end
        return
      end

      if @core_runner.valid_file? file
        print @core_runner.check_file( file ), :file => file.to_s
      end
    end

    def print( results, opt={} )
      print_results(
        results, 
        opt.merge({
          :prefix   => ' ' * 5,
          :source   => @core_runner.source
        })
      )
    end

    def print_results( results, opt={} )
      IO.popen "chcp 65001" if ENV['OS'] =~ /windows/i
      print_class = case opt[:format]
        when :vim
          'VimPrinter'
        when :nocolor
          'NoColorPrinter'
        else 
          'ConsolePrinter'
      end
      XRay.register_printer XRay.const_get( print_class )
      XRay.printer.new( results, opt ).print
    end

    def print_type(format)
      format || 'base'
    end

  end

end

if $0 == __FILE__
  XRay::CMDRunner.run
end
