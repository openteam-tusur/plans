class SelfEducation < ActiveRecord::Base
  belongs_to :work_programm

  has_enums

  FIFTH_ITEM_KINDS = %w[home_work referat test colloquium calculation]
  ALL_KINDS   = %w[lecture lab practice csr home_work referat test colloquium calculation srs exam]

  FIFTH_ITEM_KINDS.each do |kind|
    attr_accessible "#{kind}_hours", "#{kind}_control"

    validates "#{kind}_control", :presence => true, :if => "#{kind}_hours?"

    validates "#{kind}_hours",
              :presence => true,
              :numericality => { :only_integer => true, :greater_than_or_equal_to  => 0 }

    default_value_for "#{kind}_hours", 0
  end

  Loading.enum_values(:loading_kind).each do |kind|
    attr_accessible "#{kind}_hours", "#{kind}_control"

    validates "#{kind}_control", :presence => true, :if => "#{kind}_hours?"

    validates "#{kind}_hours",
              :presence => true,
              :numericality => { :only_integer => true, :greater_than_or_equal_to  => 0 },
              :if => :"need_#{kind}?"

    default_value_for "#{kind}_hours", 0

    define_method "need_#{kind}?" do
      work_programm.has_loadings_for? kind
    end
  end

  def total_hours
    ALL_KINDS.inject(0) { |sum, kind| sum += send("#{kind}_hours").to_i }
  end
end
