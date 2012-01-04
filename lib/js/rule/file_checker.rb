# encoding: utf-8

require_relative '../../helper/file_reader'


module XRay
  module JS
    module Rule
      
      class FileChecker
        
        def check_file(path)
          if merge_file? path
            check_merge_file path
          elsif !min_file?(path)
            check_func_file path
          end
        end
        
        def check_merge_file(path)
          pathes = grep_import_js_path readfile(path)

          ret = []
          ret.concat check_one_line_one_import(pathes) 
          ret.concat check_strict_import_js(pathes)
          ret.concat check_import_js_exist_and_min(path, pathes)
          ret.concat check_import_js_scope(path, pathes)
          ret
        end

        def check_func_file(path)
          ret = []
          
          unless has_doc_comment? readfile(path)
            msg = '功能文件头必须有文档注释(以/**开始的多行注释)'
            ret << LogEntry.new(msg, :warn)
          end

          ret 
        end

        def merge_file?(path)
          return path =~ /\w+-merge([-_]?\d+)?\.js$/
        end

        def min_file?(path)
          return path =~ /\w+-min\.js$/ 
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

        def check_one_line_one_import(pathes)
          ret = []
          row = 0
          pathes.each do |path|
            if row == path[:row]
              ret << LogEntry.new('一行只能有一个import文件', :error, path[:row], path[:col])
            end
            row = path[:row]
          end         
          ret
        end

        def check_strict_import_js(pathes)
          ret = []
          pathes.each do |path|
            unless /ImportJavscript\.url\(['"]?([^'"]+)['"]?\);/ =~ path[:text]
              ret << LogEntry.new('merge文件格式不正确', :error, path[:row], path[:col])
            end
          end
          ret
        end

        def has_doc_comment?(body)
          body =~ /^\s*\/\*\*[^*]*\*+([^\/*][^*]*\*+)*\//
        end

        def check_import_js_scope(path, pathes)
          path = path.sub /\\/, '/'

          # merge文件级别
          scope = path =~ /\/global\// ? :global :
              path =~ /\/page\// ? :page : nil
          ret = []

          unless scope
            return ret
          end

          prefix = File.basename(path).sub /-merge([-_]\d+)?\.js/, ''
          
          # page级别merge文件引用的文件样式
          page_pattern = %r"/page/#{prefix}(-min|(/.+))?\.js" if scope == :page
          
          abs_path = File.absolute_path(path).sub /\\/, '/' 
          app_path = abs_path.match(/^(.*?\/)(global|page)\//)[1]

          pathes.each do |path|
            url = path[:url]
            next if url =~ /\/(lib|sys)\//  # lib和sys不用检查
            next unless url =~ %r(^http://) # 相对路径不用检查

            match = /^(.*?\/)(global|module|page)\//.match url
            unless match && !app_path.index(match[1])
              ret << LogEntry.new('merge文件引用非该产品线文件', :error, path[:row], path[:col])
              next
            end

            if scope == :global && url =~ /\/page\//
              ret << LogEntry.new('产品线merge文件不能引用page文件', :error, path[:row], path[:col])
              next
            end

            if scope == :page && url =~ /\/page\// && url !~ page_pattern
              ret << LogEntry.new('页面级别merge文件只允许merge当前页面所属js文件', :error, path[:row], path[:col])
            end
          end
          
          ret
        end

        def check_import_js_exist_and_min(path, pathes)
          ret = []

          abs_path = File.absolute_path path

          match = /^.*?\bjs\b/.match abs_path
          abs_dir = match ? match[0] : '' 

          rel_dir = File.dirname abs_path

          pathes.each do |path|
            url = path[:url].sub /\?.*$/, '' # remove timestamp
            import_path = url =~ %r(^http://) ?
                File.join(abs_dir, url.sub(/.*?\bjs\b/, '')) :
                File.join(rel_dir, url)
          
            unless File.file? import_path
              ret << LogEntry.new('merge文件import的文件不存在', :error, path[:row], path[:col])
            end

            if /\b(global|page)\b/ =~ import_path && !min_file?(import_path)
              ret << LogEntry.new('merge文件需要引用压缩版的js, 如a-min.js', :warn, path[:row], path[:col])
            end
          end

          ret
        end

        def readfile(path)
          text, encoding = XRay::Helper::FileReader.readfile path
          text
        end
        
      end

    end
  end
end
