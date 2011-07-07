$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'test/unit'
require 'log_entry.rb'
require 'runner'

FIXTURE_PATH = File.expand_path( File.dirname(__FILE__) ) + '/fixtures' 
