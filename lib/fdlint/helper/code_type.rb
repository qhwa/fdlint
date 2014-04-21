module Fdlint
  module Helper

    class CodeType

      class << self

        def guess(text, filename=nil)
          if filename && !filename.empty?
            guess_by_name filename
          else
            guess_by_content text
          end
        end

        def guess_by_name( filename )
          case File.extname( filename )
          when /\.css$/i
            :css
          when /\.js$/i
            :js
          else
            :html #TODO: support more suffix
          end
        end

        def guess_by_content(text)
          return :html  if html? text
          return :css   if css? text
          :js #TODO: support more code syntaxes
        end

        def style_file?(filename)
          File.extname( filename ) =~ /(css|js|html?)$/i
        end

        def scope(filename)
          filename =~ /[\\\/]lib[\\\/]/ ? 'lib' : 'page'
        end

        private

          def html?(text)
            /^\s*</m =~ text
          end

          def css?(text)
            /^\s*@/m =~ text or /^\s*([-\*:\.#_\w]+\s*)+\{/ =~ text
          end

      end

    end
  end
end
