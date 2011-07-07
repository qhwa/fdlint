class String
    def red
        "\e[31m" << self << "\e[0m"
    end

    def purple
        "\e[35m" << self << "\e[0m"
    end

    def yellow
        "\e[33m" << self << "\e[0m"
    end
end


