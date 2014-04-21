module XRay

  module Context

    attr_accessor :scope

    def lib?
      scope == :lib
    end

    def page_level?
      scope == :page
    end

    def in_page?
      scope == :in_page
    end

  end

  class DefaultContext

    include Context

    def initialize
      @scope = :page
    end
  end


end
