require 'logger'

require 'js/parser'

if __FILE__ == $0
  path = File.expand_path '../fixtures/js/jquery-1.7.js', File.dirname(__FILE__)
  body = IO.read(path)

  parser = XRay::JS::Parser.new(body, Logger.new(STDOUT))
  program = parser.parse_program
end
