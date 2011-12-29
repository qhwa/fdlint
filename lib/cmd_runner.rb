#!/usr/bin/env ruby
require 'optparse'
require 'find'
require_relative 'runner'

if ENV['OS'] =~ /windows/i
  require 'win32console' 
  system "chcp 65001"
end

Version = "0.1"

module XRay

  class CMDOptions

    def self.parse( args )
      files = []
      options = {
        :encoding   => 'gb2312',
        :colorful   => true,
        :type       => nil,
        :check_min  => false
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
        opts.on("--checkmin", "-m", "check minified files too. (e.g. *-min.js; *-min.css)") do
          options[:check_min] = true
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
        Find.find(file) do |f|
          check_file(f, opt) unless File.directory? f
        end
        return
      end

      if @core_runner.valid_file? file
        f = file.to_s
        results = @core_runner.check_file( f )

        if results.empty?
          print "[OK]".white.green_bg << " #{f}" << "\n"
        elsif opt[:list]
          puts "[EE]".white.red_bg << " #{f}"
          print_results(
            results, 
            opt.merge(:prefix => ' ' * 5)
          )
        else
          puts ""
          puts "[EE] #{f}".white.magenta_bg
          print_results_with_source(
            results, 
            @core_runner.source, 
            opt.merge(:prefix => '    > ')
          )
          puts ""
        end
      end
    end

    def print_results( results, opt={} )
      prf = opt[:prefix] || ''
      suf = opt[:suffix] || ''
      results.each do |r|
        t = r.send( opt[:colorful] ? :to_color_s : :to_s )
        puts prf + t + suf
      end
    end

    def print_results_with_source( results, source, opt={} )
      if source
        lines = source.split(/\r\n|\n|\r/)
        prf = opt[:prefix] || ''
        suf = opt[:suffix] || ''
        results.each do |r|
          t = r.send( opt[:colorful] ? :to_color_s : :to_s )
          if r.row && r.row > 0
            col = r.column - 1
            row = r.row - 1
            line_t = lines[row]
            left = col - 50
            right = col + 50
            left = 0 if left < 0
            puts prf + lines[row][left..right].gsub(/\t/, ' ')
            puts prf + ' ' * (col - left) << '^ ' << t
            puts "\n"
          else
            puts t + suf + "\n"
          end
        end
      else
        print_results
      end
    end


  end

end

if $0 == __FILE__
  XRay::CMDRunner.run
end
