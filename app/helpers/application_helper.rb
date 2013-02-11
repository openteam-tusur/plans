module ApplicationHelper
  def work_plan_api_url(work_plan)
    "#{root_url}api/v1/work_plans/#{work_plan.id}"
  end

  def indicate_validity(item)
    "#{item} " << (@work_programm.as_json[:validations][item] ? 'success' : 'warning')
  end
end
