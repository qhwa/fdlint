module XRay

  def self.printer
    @@printer
  end

  def self.register_printer(klass)
    @@printer = klass
  end

  class BasePrinter
  
    XRay.register_printer self

    def initialize(results, opt)
      @results, @opt = results, opt
    end

    def print
    end

  end

end
