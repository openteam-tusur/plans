@init_check_valid = () ->
  $.ajax(
    headers: {'Accept': 'application/json'}
  ).done (data, status, jqXHR) ->
    validations = $.parseJSON(jqXHR.responseText).validations
    $.each validations, (key, valid) ->
      target = $('.'+key)
      if valid
        target.removeClass('warning')
        target.addClass('success')
      else
        target.addClass('warning')
        target.removeClass('success')

    $.ajax(
      url: window.location.pathname + '/get_event_actions'
      dataType: 'html'
      success: (data, status, jqXHR) ->
        $('.event_actions').html(jqXHR.responseText)
    )
