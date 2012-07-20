# encoding: utf-8

gos_gmu = Gos.find_or_initialize_by_code_and_speciality("061000", "Государственное и муниципальное управление")
gos_gmu.approved_on = "2000-03-17"
gos_gmu.save!
