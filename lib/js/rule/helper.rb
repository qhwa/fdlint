module XRay
  module JS
    module Rule
      
      module Helper
        def find_expr_member(expr)
          while expr.is_a?(Expression) && !yield(expr) 
            expr = expr.left
          end
          expr && expr.is_a?(Expression) && yield(expr) ? expr : nil
        end

        def has_doc_comment?(body)
          body =~ /^\s*\/\*\*[^*]*\*+([^\/*][^*]*\*+)*\//
        end

        def readfile(path)
          text, encoding = XRay::Helper::FileReader.readfile path
          text
        end

        def merge_file?(path)
          return path =~ /\w+-merge([-_]?\d+)?\.js$/
        end

        def min_file?(path)
          return path =~ /\w+-min\.js$/ 
        end

        def func_file?(path)
          !merge_file?(path) and !min_file?(path)
        end

        def grep_import_js_path(body)
          lines = body.split /\n/
          pattern = /(ImportJavscript\s*\.\s*url\s*\(\s*['"]?([^'"]+)['"]?\s*\)\s*;?)/

          pathes = []
          lines.each_with_index do |line, index|
            line.scan(pattern) do |text, url|
              pathes << {
                :text => text,
                :url => url,
                :row => index + 1,
                :col => Regexp.last_match.begin(0) + 1 
              }
            end
          end
          pathes
        end


        def scope(path)
          parts = path.split(/\\\//)
          if parts.include? 'global'
            :global
          elsif parts.include? 'page'
            :page
          elsif parts.include? 'lib' or parts.include? 'sys'
            :lib
          end
        end

        def global_scope?( path )
          scope(path) == :global
        end

        def page_scope?( path )
          scope(path) == :page
        end

        def lib_scope?( path )
          scope(path) == :lib
        end

        def relative?( path )
          path !~ %r(^https?://)
        end

        def app( path )
          sep = /(?:\\|\/)/
          path[/#{sep}app#{sep}(.*?)#{sep}(?:.+#{sep})*(global|page|module)(?:\\|\/)/, 1]
        end

        def results_to_logs( results )
          results.map do |r|
            msg, level, row, column = *r
            LogEntry.new(msg, level, row || 0, column || 0)
          end
        end
      end

    end
  end
end

