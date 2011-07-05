#!/usr/bin/env ruby
require 'optparse'
require_relative 'runner'

module XRay
    class CMDOptions
        
        def self.parse( args )

            css_files, js_files, html_files, common_files = [], [], [], []
            encoding = :gb2312
            opts = OptionParser.new do |opts|
                opts.banner = "Usage: xray"
                %w(css js html).each do |type|
                    opts.on("--#{type} files", Array, "check #{type} files") do |files|
                        eval("#{type}_files").concat files if files
                    end
                    opts.on("files", Array, "automatic detect file type") do |files|
                        common_files.concat files if files
                    end
                    opts.on("--charset set", "-c", "file charset") do |enc|
                        encoding = enc
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
                :encoding   => encoding,
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
            enc     = options[:encoding]
            %w(css js html).each do |type|
                files = options[:"#{type}_files"]
                files.each { |file| check_file file, type, enc } if files
            end

            options[:common_files].each do |file|
                check_file file, get_file_type(file), enc
            end
        end

        private
        def self.check_file( file, type=:html, enc=:gb2312)
            puts "checking #{type} file: #{file}"
            content = IO.read(file, :encoding=>enc.to_s)
            content.encode! 'utf-8'
            runner = XRay::Runner.new
            runner.send :"check_#{type}", content
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
