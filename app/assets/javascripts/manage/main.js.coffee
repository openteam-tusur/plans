$ ->
  init_toc_navigation()       if $('.toc').length
  init_calculate_total()      if $('.work_programm_wrapper').length
  init_ajaxed()               if $('.ajaxed').length
  init_actions_handlers()     if $('.actions').length
