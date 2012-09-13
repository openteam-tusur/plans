module ApplicationHelper
  def indicate_validity(item)
    "#{item} " << (@work_programm.as_json[:validations].key?(item) ? 'success' : 'warning')
  end
end
