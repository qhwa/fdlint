# encoding: utf-8
require_relative '../../log_entry'

module XRay
  module CSS
    module Rule

      class CompressionChecker
        
        def initialize( opt={} )
          @opt = opt.dup
        end
        
        def check( name )
          check_items([
            :has_minified_in_same_folder
          ], name)
        end

        def check_has_minified_in_same_folder( name )
          unless is_min_file?(name) or is_merge_file?(name) or File.exist?( name.sub(/\.css$/,'-min.css') )
            [LogEntry.new('发布上线的文件需要压缩，命名规则如a.js->a-min.js，且两者在同一目录下', :warn)]
          end
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

        def is_merge_file?( name )
          name =~ /merge\.css$/
        end

        def is_min_file?( name )
          name =~ /min\.css$/
        end

      end

    end
  end
end
