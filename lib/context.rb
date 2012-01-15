module XRay

  module Context

    attr_accessor :scope

    def lib?
      scope == :lib
    end

    def page?
      scope == :page
    end

  end

  class DefaultContext

    include Context

    def initialize
      @scope = :page
    end
  end


end
