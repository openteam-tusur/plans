class Person
  attr_accessor :post, :name, :science_post
  def initialize(name, post, science_post = "")
    self.post = post
    self.name = name
    self.science_post = science_post
  end

  def short_name
    "#{name.split(' ')[0]} #{name.split(' ')[1][0]}.#{name.split(' ')[2][0]}."
  end
end
