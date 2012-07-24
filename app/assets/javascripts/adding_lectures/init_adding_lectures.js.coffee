@init_adding_lectures = ->
  $('.add_lecture').on 'ajax:success', (event, data, status, xhr) ->
    $this = $(this)
    form_wrapper = $this.siblings('.form_wrapper')

    form_wrapper.html(data)

    form_wrapper.on 'ajax:success', (event, data, status, xhr) ->
      data = $(data)

      if data.find('input').length
        form_wrapper.html(data)
      else
        form_wrapper.off().html('')
        last_tr = form_wrapper.siblings('.lectures').find('tr').last()
        data.insertAfter(last_tr)
