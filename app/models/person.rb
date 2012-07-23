class Person
  attr_accessor :post, :name, :science_post, :short_name

  def initialize(options)
    options.each do |field, value|
      self.send("#{field}=", value)
    end
  end

  def short_name
    @short_name ||= "#{name.split(' ')[0]} #{name.split(' ')[1][0]}.#{name.split(' ')[2][0]}."
  end

  def to_a
    ["#{post}\n#{science_post}", "______________", short_name]
  end

  NIL = Person.new(:name => '-'*10, :post => '-'*10, :short_name => '-'*10)
end
