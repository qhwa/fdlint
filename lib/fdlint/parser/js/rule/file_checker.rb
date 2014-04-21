# encoding: utf-8

require_relative '../../helper/file_reader'
require_relative 'helper'
require_relative '../../rule'


module XRay
  module JS
    module Rule
      
      class FileChecker

        include Helper, XRay::Rule
        
        def check_file(path)
          src = readfile(path)
          ret = results_to_logs check_js_file( path, src )

          if merge_file? path
            pathes = grep_import_js_path( src )
            ret.concat results_to_logs( check_js_merge_file( path, src, pathes ) )
            ret.concat results_to_logs( check_merge_imports( pathes, path ) )
          end
          ret
        end

        def check_merge_imports( pathes, path )
          ret = []
          pathes.each do |import|
            r = check_js_merge_importing import, pathes, path
            ret.concat r
          end
          ret
        end
        
        
      end

    end
  end
end
