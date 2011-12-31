module XRay
  
  class FileValidator
    def initialize( options )
      @options = options
      @validators = []
    end

    def add_validator( val )
      @validators << val
    end

    def add_validators( vals)
      vals.each { |val| add_validator val }
    end

    def check( file )
      results = []
      @validators.each do |val|
        if val.respond_to? :check_file
          val_results = val.check_file(file)
          if val_results
            if val_results.is_a? Array
              results.concat val_results
            else
              results << val_results
            end
          end
        end
      end
      results
    end

    alias_method :validate, :check

  end

end
