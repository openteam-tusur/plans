@init_add_discipline = () ->
  $('.add_discipline').on 'ajax:success', (evt, data, status, jqXHR) ->
    link = $(this).hide()
    list = link.siblings('ul')
    response = $(jqXHR.responseText)

    $('<div />', { class: 'form_wrapper' }).insertAfter(link) unless $('.form_wrapper', link.parent()).length

    form_wrapper = $('.form_wrapper', link.parent())
    form_wrapper.html(response)
    init_add_autocomplete()
    init_cancel_handler()

    form_wrapper.on 'ajax:success', (evt, data, status, jqXHR) ->
      if $(jqXHR.responseText).find('input').length
        form_wrapper.html(jqXHR.responseText)
        init_add_autocomplete()
        init_cancel_handler()
      else
        list.append(jqXHR.responseText)
        form_wrapper.html('').off()
        link.show()

    false
