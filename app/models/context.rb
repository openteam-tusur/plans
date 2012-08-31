class Context < ActiveRecord::Base
  attr_accessible :title
  has_many :subdepartments
  esp_auth_context :subcontext => Subspeciality

  has_many :subcontexts, :class_name => Discipline,
    :finder_sql => proc { "
        SELECT disciplines.*
        FROM disciplines
          JOIN subspecialities ON disciplines.subspeciality_id = subspecialities.id
          JOIN specialities ON subspecialities.speciality_id = specialities.id
          JOIN subdepartments ON disciplines.subdepartment_id = subdepartments.id OR subspecialities.subdepartment_id = subdepartments.id
        WHERE subdepartments.context_id = #{id}
          AND specialities.gos_generation = '2'
        ORDER BY disciplines.title, subspecialities.id
        " }
end

# == Schema Information
#
# Table name: contexts
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  ancestry   :string(255)
#  weight     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

