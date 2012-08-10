class WorkProgrammPresentor
  attr_accessor :work_programm, :json

  def initialize(work_programm)
    self.work_programm = work_programm
    self.json = work_programm.as_json[:validations]
  end

  def indicate_paragraph(field)
    "#{field} ".tap do |string|
      if json.key?(field.to_sym)
        string << (json[field.to_sym] ? 'success' : 'warning')
      end
    end
  end
end
