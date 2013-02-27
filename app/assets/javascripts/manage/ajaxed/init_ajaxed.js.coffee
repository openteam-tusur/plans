cancel_handler = () ->
  $('.cancel').on 'click', ->
    link = $(this)
    if link.hasClass('new_record')
      link.closest('.ajaxed_item').remove()

    false

@init_ajaxed = () ->
  $('.ajaxed').on 'ajax:complete', (evt, jqXHR, status) ->
    context = $(evt.target)
    didactic_units = context.closest('.ajaxed').siblings('.didactic_units_wrapper')

    if context.hasClass('new_record') && context.hasClass('in_table')
      context.closest('tr').before(jqXHR.responseText)
    else if context.hasClass('new_record')
      context.before(jqXHR.responseText)
    else
      if context.hasClass('new_work_programm')
        if $(jqXHR.responseText).find('.error').length
          context.closest('.ajaxed_item').replaceWith(jqXHR.responseText)
        else if $(jqXHR.responseText).hasClass('ajaxed_item')
          context.closest('li.noborder').before(jqXHR.responseText)
          context.closest('li.noborder .ajaxed_item').remove()
        else
          window.location = $("<div>").html(jqXHR.responseText).html()
        return

      ajaxed_item = context.closest('.ajaxed_item')
      ajaxed_item.replaceWith(jqXHR.responseText)

    if didactic_units.length && context.closest('.ajaxed').hasClass('exercises')
      $.ajax
        url: window.location.pathname + '/get_didactic_units'
        dataType: 'html'
        success: (data, status, jqXHR) ->
          didactic_units.html(jqXHR.responseText)

    init_authors_autocomplete()  if $('.need_autocomplete').length
    init_publication_variation() if $('#publication_location').length
    init_calculate_total()
    init_check_valid()           if $('.work_programm_wrapper').length
    cancel_handler()
