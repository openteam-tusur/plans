class API::Entities::Discipline < Grape::Entity
  expose :id
  expose :title
  expose :special_work
  expose :weeks_count

  expose :cycle do |object|
    { :code => object.cycle_code, :title => object.cycle }
  end

  expose :subdepartment, :using => API::Entities::Subdepartment

  expose :loadings do |object, options|
    API::Entities::Loading.represent object.loadings
                                       .actual
                                       .where(:semester_id => options[:semester])
                                       .where(:kind => %w[lecture lab practice csr])
                                       .order(:kind)
  end

  expose :checks do |object, options|
    API::Entities::Check.represent object.checks
                                     .actual
                                     .where(:semester_id => options[:semester])
                                     .order(:kind)
  end
end

