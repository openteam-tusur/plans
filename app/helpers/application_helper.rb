module ApplicationHelper
  def work_plan_api_url(work_plan)
    "#{root_url}api/v1/work_plans/#{work_plan.subspeciality_id}"
  end

  def programm_api_url(programm)
    "#{root_url}api/v1/programms/#{programm.subspeciality_id}"
  end

  def indicate_validity(item)
    "#{item} " << (@work_programm.as_json[:validations][item] ? 'success' : 'warning')
  end

  def manage_work_programm_path(work_programm)
    discipline = work_programm.discipline
    manage_year_speciality_subspeciality_discipline_work_programm_path(discipline.subspeciality.speciality.year, discipline.subspeciality.speciality, discipline.subspeciality, discipline, work_programm)
  end

  def new_manage_work_programm_path(discipline)
    new_manage_year_speciality_subspeciality_discipline_work_programm_path(discipline.subspeciality.speciality.year, discipline.subspeciality.speciality, discipline.subspeciality, discipline)
  end
end
