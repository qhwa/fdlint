# encoding: utf-8
require_relative '../../log_entry'

module XRay
  module CSS
    module Rule

      class FileNameChecker
        
        def initialize( opt={} )
          @opt = opt.dup
        end
        
        def check( name )
          check_items([
            :ad,
            :underscore,
            :seperator,
            :letters
          ], name)
        end

        def check_ad( name )
          [LogEntry.new('路径和文件名中不应该出现ad', :warn)] if name =~ /ad/
        end

        def check_underscore( name )
          [LogEntry.new('文件名中单词的分隔符应该使用中横线“-”', :warn)] if File.basename(name) =~ /_/
        end

        def check_seperator( name )
          [LogEntry.new('文件夹只有需要版本区分时才可用中横线分隔，如fdev-v3', :warn)] if File.dirname(name) =~ /-(?!v?[\d.])/
        end

        def check_letters( name )
          [LogEntry.new('文件夹和文件命名必须用小写字母', :warn)] if name =~ /[A-Z]/
        end

        protected
        def check_items( items, name )
          results = []
          items.each do |i|
            r = self.send(:"check_#{i}", name)
            results.concat r if Array === r
          end
          results
        end

      end

    end
  end
end
