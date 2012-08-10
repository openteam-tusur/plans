cancel_handler = () ->
  $('.cancel', '.missions_wrapper').on 'click', ->
    link = $(this)
    new_record = link.hasClass('new_record')

    if new_record
      link.closest('li').remove()

    false

@init_manage_missions = () ->
  $('.missions_wrapper').on 'ajax:success', (evt, data, status, jqXHR) ->
    context = $(evt.target)

    if context.hasClass('new')
      context.siblings('.mission_list').append(jqXHR.responseText)

    else
      context.closest('li').replaceWith(jqXHR.responseText)

    init_check_valid()
    cancel_handler()
