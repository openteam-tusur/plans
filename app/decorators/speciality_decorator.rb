class SpecialityDecorator < Draper::Decorator
  delegate :code, :title, :year

  def degree
    I18n.t model.degree, :scope => 'activerecord.values.speciality'
  end
end
