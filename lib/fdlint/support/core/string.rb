class String

  def blank?
    !(self =~ /\S/)
  end

end
