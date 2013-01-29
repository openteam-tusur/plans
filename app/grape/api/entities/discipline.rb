class API::Entities::Discipline < Grape::Entity
  expose :id
  expose :title

  expose :cycle do |object|
    { :code => object.cycle_code, :title => object.cycle }
  end
  expose :subfaculty do |object|
    { :abbr => object.provided_subdepartment.abbr, :title => object.provided_subdepartment.title }
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

