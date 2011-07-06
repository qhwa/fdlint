class String
    def red
        "\e[31m" << self << "\e[0m"
    end

    def yellow
        "\e[33m" << self << "\e[0m"
    end
end


