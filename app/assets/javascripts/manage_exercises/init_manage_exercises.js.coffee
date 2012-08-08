$.fn.count_hours = () ->
  context = $(this)
  total = Number(context.find('.rup_hours td span').html())
  total_hours_wrapper = context.find('.total_hours td')

  res = 0
  context.find('.hours').each (index, item) ->
    res += Number($(item).html())

  total_hours_wrapper.find('span').html(res)
  if res != total
    total_hours_wrapper.addClass('warning')
  else
    total_hours_wrapper.removeClass('warning')

$.fn.remote_hadler = () ->
  contexts = $(this)
  contexts.on 'ajax:success', (evt, data, status, jqXHR) ->
    context = $(evt.target)
    tbody = context.closest('tbody')
    new_record = context.hasClass('new_record')

    if new_record
      context.closest('tr').before(jqXHR.responseText)

    else
      context.closest('tr').replaceWith(jqXHR.responseText)

    tbody.count_hours()
    init_calculate_total()
    cancel_handler()

cancel_handler = () ->
  $('.cancel', '.exercises').on 'click', ->
    link = $(this)
    new_record = link.hasClass('new_record')

    if new_record
      link.closest('.exercise_form').remove()

    false

@init_manage_exercises = () ->
  $('.exercises').remote_hadler()
