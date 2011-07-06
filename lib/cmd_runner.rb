#!/usr/bin/env ruby
require 'optparse'
require 'logger'
require_relative 'helper/colored'

require_relative 'runner'

Version = "0.1"

module XRay
    class CMDOptions
        
        def self.parse( args )

            css_files, js_files, html_files, common_files = [], [], [], []
            options = {
                :encoding   => :gb2312,
                :css_files  => css_files,
                :js_files   => js_files,
                :html_files => html_files,
                :common_files => common_files
            }

            opts = OptionParser.new do |opts|
                opts.banner = "Usage: xray"
                %w(css js html).each do |type|
                    opts.on("--#{type} files", Array, "check #{type} files") do |files|
                        eval("#{type}_files").concat files if files
                    end
                    opts.on("--charset set", "-c", "file charset") do |enc|
                        options[:encoding] = enc
                    end
                    opts.on("--debug", "-d", "print debug info") do |dbg|
                        options[:debug] = true
                    end
                    opts.on("--verbose", "-V", "print detail info") do |vbs|
                        options[:verbose] = true
                    end
                end
            end

            begin
                rest = opts.parse! args
                common_files.concat rest
                raise ArgumentError.new("") if (css_files + js_files + html_files + common_files).empty?
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
            enc     = options[:encoding]
            %w(css js html).each do |type|
                files = options[:"#{type}_files"]
                files.each { |file| check_file file, type, options } if files
            end

            options[:common_files].each do |file|
                check_file file, get_file_type(file), options
            end
        end

        private
        def check_file( file, type=:html, opt)
            begin
                content = IO.read(file, :encoding=>opt[:encoding].to_s)
            rescue => e
                puts "[ERROR] #{e.to_s}"
                return
            end

            content.encode! 'utf-8'

            runner = XRay::Runner.new(opt)
            
            good, results = runner.send :"check_#{type}", content
            if good
                puts "Successful! This file is well written."
            elsif opt[:verbose]
                print_results_with_source results, content
            else
                print_results results
            end
        end

        def get_file_type( name )
            if name =~ /\.css$/i
                :css
            elsif name =~ /\.js/i
                :js
            else
                :html
            end
        end

        def print_results( results )
            results.print
        end

        def print_results_with_source( results, source )
          lines = source.split("\n")
          results.each do |r|
            pos = r.node.position
            puts lines[pos.line]
            puts ' ' * pos.column << '^ ' << color_text(r)
            puts "\n"
          end
        end

        def color_text( result )
            t = "[#{result.level}] #{result.message}"
            if result.warn?
                t.yellow
            elsif result.fatal?
                t.red
            elsif result.error?
                t.purple
            else
                t
            end
        end

    end
end


if $0 == __FILE__
    XRay::CMDRunner.run
end
