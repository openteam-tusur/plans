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
#--
# generated by 'annotated-rails' gem, please do not remove this line and content below, instead use `bundle exec annotate-rails -d` command
#++
# Table name: departments
#
# * id         :integer         not null
#   title      :string(255)
#   abbr       :string(255)
#   number     :integer
#   year_id    :integer
#   deleted_at :datetime
#   created_at :datetime        not null
#   updated_at :datetime        not null
#
#  Indexes:
#   index_departments_on_year_id  year_id
#--
# generated by 'annotated-rails' gem, please do not remove this line and content above, instead use `bundle exec annotate-rails -d` command
#++
