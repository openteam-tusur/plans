# encoding: utf-8

class API::Entities::ProvidedDiscipline < Grape::Entity
  expose :abbr
  expose(:goses) { |model, options|
    hash = {}
    model.disciplines.actual.order('title ASC').each do |discipline|
      hash[discipline.speciality.gos_generation] ||= {}
      hash[discipline.speciality.gos_generation]["#{discipline.speciality.title} (#{discipline.speciality.degree_text})"] ||= {}
      hash[discipline.speciality.gos_generation]["#{discipline.speciality.title} (#{discipline.speciality.degree_text})"]["Набор #{discipline.speciality.year.number} года и последующих лет, #{discipline.subspeciality.education_form_text} форма обучения"] ||= []
      hash[discipline.speciality.gos_generation]["#{discipline.speciality.title} (#{discipline.speciality.degree_text})"]["Набор #{discipline.speciality.year.number} года и последующих лет, #{discipline.subspeciality.education_form_text} форма обучения"] << discipline.title.gsub(/\s*-\s*/, ' - ')
    end
    hash
  }
end
