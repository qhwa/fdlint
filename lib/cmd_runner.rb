#!/usr/bin/env ruby
require 'optparse'
require 'pathname'
require_relative 'runner'

Version = "0.1"

module XRay

  class CMDOptions

    def self.parse( args )
      files = []
      options = {
        :encoding   => 'gb2312',
        :colorful   => true,
        :type       => nil
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
        opts.on("--list", "-l", "list results without source") do
          options[:list] = true
          options[:colorful] = false
        end
      end

      begin
        rest = opts.parse! args
        files.concat rest
        raise ArgumentError.new("") if files.empty?
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
      files.each do |file|
        check_file file, options
      end
    end

    private
    def check_file( file, opt)

      if File.directory? file
        Pathname.new( file ).each_child do |f|
          check_file( f, opt )
        end
        return
      end

      if @core_runner.valid_file? file
        f = file.to_s
        good, results = @core_runner.check_file( f )

        if good
          print "[OK]".green_bg << " #{f}" << "\n"
        elsif opt[:list]
          puts "[EE]".red_bg << " #{f}"
          @core_runner.print_results :prefix => ' ' * 5
        else
          puts ""
          puts "[EE] #{f}".purple_bg
          @core_runner.print_results_with_source :prefix => '    > '
          puts ""
        end
      end
    end

  end

end

if $0 == __FILE__
  XRay::CMDRunner.run
end
