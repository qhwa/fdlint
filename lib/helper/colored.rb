class String

  def red
    color 1
  end

  def purple
    color 5
  end

  def yellow
    color 3
  end

  def color( fore, bg=nil )
    "\e[3#{fore}m" << self << "\e[0m"
  end

end
