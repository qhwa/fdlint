module XRay

  class Context

    attr_accessor :scope

    @scope = :page

    def lib?
      scope == :lib
    end

    def page?
      scope == :page
    end

  end

end
