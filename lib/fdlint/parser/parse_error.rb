class Fdlint::Parser::ParseError < RuntimeError

  attr_reader :position

  def initialize(msg = nil, position = nil)
    super msg
    @position = position
  end

end
