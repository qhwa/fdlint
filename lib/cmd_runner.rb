#!/usr/bin/env ruby
require 'optparse'
require_relative 'runner'

module XRay
    class CMDOptions
        
        def self.parse( args )

            css_files, js_files, html_files, common_files = [], [], [], []
            opts = OptionParser.new do |opts|
                opts.banner = "Usage: xray"
                %w(css js html).each do |type|
                    opts.on("--#{type} files", Array, "check #{type} files") do |files|
                        eval("#{type}_files").concat files if files
                    end
                    opts.on("files", Array, "automatic detect file type") do |files|
                        common_files.concat files if files
                    end
                end
            end

            begin
                rest = opts.parse! args
            rescue => e
                puts e.message.capitalize + "\n\n"
                puts opts
                exit 1
            end

            {
                :css_files  => css_files,
                :js_files   => js_files,
                :html_files => html_files,
                :common_files => common_files.concat(rest)
            }

        end
    end

    class CMDRunner

        def self.run
            options = XRay::CMDOptions.parse ARGV
            %w(css js html).each do |type|
                files = options[:"#{type}_files"]
                files.each { |file| check_file file, type } if files
            end

            options[:common_files].each do |file|
                check_file file, get_file_type(file)
            end
        end

        private
        def self.check_file( file, type=:html)
            puts "checking #{type} file: #{file}"
            runner = XRay::Runner.new
            runner.send :"check_#{type}", IO.read(file)
        end

        def self.get_file_type( name )
            if name =~ /\.css$/
                :css
            elsif name =~ /\.js/
                :js
            else
                :html
            end
        end

    end
end


if $0 == __FILE__
    XRay::CMDRunner.run
end
