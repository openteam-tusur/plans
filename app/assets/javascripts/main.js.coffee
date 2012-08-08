$ ->
  init_add_programm()
  init_add_text()
  init_add_discipline()
  init_add_work_programm() if $('.add_work_programm').length
  init_manage_exercises()
  init_manage_missions()
  init_calculate_total()
  init_collapser() if $('.collapsible').length
