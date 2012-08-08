cancel_handler = () ->
  cancel_link = $('.cancel_link')
  cancel_link.on 'click', ->
    cancel_link.closest('form').hide()
    cancel_link.closest('form').siblings('a').show()
    false

@init_add_work_programm = () ->
  $('.add_work_programm_wrapper').on 'ajax:success', (evt, data, status, jqXHR) ->
    if (link = $(evt.target)).is('a')
      link.hide()
      link.after(jqXHR.responseText)
      cancel_handler()
    else
      if $(jqXHR.responseText).find('.error').length
        $(evt.target).replaceWith(jqXHR.responseText)
        cancel_handler()
      else
        window.location = $(jqXHR.responseText).find('.resource_path').html()
