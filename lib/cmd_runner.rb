#!/usr/bin/env ruby
require 'optparse'
require_relative 'runner'

Version = "0.1"

module XRay

  class CMDOptions

    def self.parse( args )
      css, js, html, common = [], [], [], []  
      options = {
        :encoding   => :gb2312,
        :css_files  => css,
        :js_files   => js,
        :html_files => html,
        :common_files => common
      }


      opts = OptionParser.new do |opts|
        opts.banner = "Usage: xray"
        %w(css js html).each do |type|
          opts.on("--#{type} files", Array, "check #{type} files") do |files|
            options[:"#{type}_files"].concat files if files
          end
          opts.on("--charset set", "-c", "file charset") do |enc|
            options[:encoding] = enc
          end
          opts.on("--debug", "-d", "print debug info") do |dbg|
            options[:debug] = true
          end
          opts.on("--list", "-l", "list results without source") do |l|
            options[:list] = true
          end
        end
      end

      begin
        rest = opts.parse! args
        common.concat rest
        raise ArgumentError.new("") if (css + js + html + common).empty?
      rescue => e
        puts e.message.capitalize + "\n\n"
        puts opts
        exit 1
      end
      options
    end
  end

  class CMDRunner

    def self.run
        self.new.run
    end

    def run
      options = XRay::CMDOptions.parse ARGV
      %w(css js html).each do |type|
        files = options[:"#{type}_files"]
        files.each { |file| check_file file, type, options } if files
      end

      options[:common_files].each do |file|
        check_file file, options
      end
    end

    private
    def check_file( file, type=:html, opt)
      runner = XRay::Runner.new(opt)
      good, results = runner.check_file file
      if good
        puts "Successful! This file is well written."
      elsif opt[:list]
        runner.print_results
      else
        runner.print_results_with_source
      end
    end

  end

end

if $0 == __FILE__
  XRay::CMDRunner.run
end
