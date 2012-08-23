@init_check_valid = () ->
  $.ajax(
    headers: {'Accept': 'application/json'}
  ).done (data, status, jqXHR) ->
    validations = $.parseJSON(jqXHR.responseText).validations
    $.each validations, (key, valid) ->
      target = $('.'+key)
      if key == 'whole_valid'
        if valid
          console.log 'valid'
          $('.download_link').children('a').removeClass('hide')
          $('.download_link').children('div').removeClass('show').addClass('hide')
        else
          console.log 'nevalid'
          $('.download_link').children('div').removeClass('hide')
          $('.download_link').children('a').removeClass('show').addClass('hide')

      if valid
        target.removeClass('warning')
        target.addClass('success')
      else
        target.addClass('warning')
        target.removeClass('success')
