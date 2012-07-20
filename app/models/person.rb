class Person
  attr_accessor :post, :name
  def initialize(post, name)
    self.post = post
    self.name = name
  end

  def short_name
    "#{name.split(' ')[0]} #{name.split(' ')[1][0]}.#{name.split(' ')[2][0]}."
  end
end
