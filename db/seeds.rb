# encoding: utf-8

gos_gmu = Gos.find_or_initialize_by_speciality_code('080504.65') do |gos_gmu|
  gos_gmu.update_attributes :code => '061000',
                            :title => 'Государственное и муниципальное управление',
                            :approved_on => '2000-03-17'
end
