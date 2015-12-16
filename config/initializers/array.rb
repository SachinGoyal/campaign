class Array
  def diff(o)
    (o - self) + (self - o)    # alternatively: (o + self) - (o & self)
  end
end