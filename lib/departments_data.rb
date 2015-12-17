require 'singleton'

class DepartmentsData
  include Singleton

  attr_accessor :departments_data

  def initialize
    update_departments_data
  end

  def department_data_with_subdepartments(department)
    department = departments_data.select { |e| e['abbr'] == department.abbr }.first.try(:dup) || {}
    department["subdepartments"] = department['chairs']
    department.delete('chairs')
    department
  end

  def department_data(department)
    data = department_data_with_subdepartments(department)
    data["chief"] = data["dean"]
    clean data
  end

  def subdepartment_data(subdepartment)
    data = department_data_with_subdepartments(subdepartment.department)['subdepartments'] || []

    clean data.select { |e| e['abbr'] == subdepartment.abbr }.first
  end

  def departments
    departments_data
  end

  private

  def check_update_time
    Time.zone.now - 12.hours > @last_data_update ? update_departments_data : nil
  end

  def update_departments_data
    RestClient::Request.execute(
      method: :get,
      url:"#{Settings['directory.url']}/api/structure",
      timeout: 600,
      headers: { :Accept => 'application/json', :timeout => 600 }
    ) do |response, request, result, &block|
        @departments_data = JSON.parse(response.body)
    end
    @last_data_update = Time.zone.now
  end

  def clean(data)
    %w(surname name patronymic deleted_at id emails_list).each{|e| data["chief"].delete(e) if data["chief"]}
    %w(subdepartments dean ).each{|e| data.delete(e) if data }
    data
  end
end
