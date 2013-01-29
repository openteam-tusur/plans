class API::Entities::Discipline < Grape::Entity
  expose :id
  expose :title
  expose :cycle_code
  expose :cycle
  expose :subfaculty_abbr do |object|
    object.provided_subdepartment.abbr
  end

  expose :loadings do |object, options|
    API::Entities::Loading.represent object.loadings
                                       .where(:semester_id => options[:semester])
                                       .where(:loading_kind => %w[lecture lab practice csr])
                                       .order(:loading_kind)
  end

  expose :checks do |object, options|
    API::Entities::Check.represent object.checks
                                     .where(:semester_id => options[:semester])
                                     .order(:check_kind)
  end
end

