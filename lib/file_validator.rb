module XRay
  
  class FileValidator
    def initialize( options )
      @options = options
      @validators = []
    end

    def add_validator( val )
      @validators << val
    end

    def check( file )
      results = []
      @validators.each do |val|
        val_results = val.check( file )
        results.concat( val_results ) unless val_results.nil? or val_results.empty?
      end
      results
    end

    alias_method :validate, :check

  end

end
