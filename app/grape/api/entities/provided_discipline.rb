# encoding: utf-8

class API::Entities::ProvidedDiscipline < Grape::Entity
  expose :abbr
  expose(:goses) { |model, options|
    hash = {}
    model.disciplines.actual.order('title ASC').each do |discipline|
      title = discipline.title.gsub(/\s*-\s*/, ' - ')
      hash[discipline.speciality.gos_generation] ||= {}
      hash[discipline.speciality.gos_generation]["#{discipline.speciality.code}.#{discipline.speciality.degree} #{discipline.speciality.title} (#{discipline.speciality.degree_text})"] ||= {}
      hash[discipline.speciality.gos_generation]["#{discipline.speciality.code}.#{discipline.speciality.degree} #{discipline.speciality.title} (#{discipline.speciality.degree_text})"]["Набор #{discipline.speciality.year.number} года и последующих лет, #{discipline.subspeciality.education_form_text} форма обучения #{discipline.subspeciality.reduced_text}".strip] ||= {}
      hash[discipline.speciality.gos_generation]["#{discipline.speciality.code}.#{discipline.speciality.degree} #{discipline.speciality.title} (#{discipline.speciality.degree_text})"]["Набор #{discipline.speciality.year.number} года и последующих лет, #{discipline.subspeciality.education_form_text} форма обучения #{discipline.subspeciality.reduced_text}".strip][title] = discipline.work_programms.last.try(:file_url)
    end
    hash
  }
end
