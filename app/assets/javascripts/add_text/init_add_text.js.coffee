@init_add_text = () ->
  data_params = {
    '_method': 'put'
    'authenticity_token': $('head meta[name=csrf-token]').attr('content')
    'work_programm': {}
  }

  $('.add_text').on 'click', ->
    $this = $(this).hide()
    kind = $this.attr('class').replace('add_text ', '')
    url = window.location.href
    work_programm = {}

    unless $('textarea#'+kind).length
      $.ajax(
        type: 'GET'
        url: url
        dataType: 'json'
      ).done ( data, status, jqXHR ) ->
        work_programm = JSON.parse jqXHR.responseText
        form = $('<form/>').insertAfter($this)
        input_div = $('<div class="input" />').appendTo(form)
        textarea = $('<textarea id='+kind+'/>').appendTo(input_div)
        textarea.val(work_programm[kind])
        buttons = $('<div class="buttons"/>').appendTo(form)
        submit = $('<a href="#" class="submit_link">Сохранить цели</a>').appendTo(buttons)
        cancel = $('<a href="#" class="cancel_link">Отмена</a>').appendTo(buttons)
        init_cancel_handler()
        submit.on 'click', ->
          data_params.work_programm[kind] = textarea.val()
          $.ajax(
            type: 'POST'
            url: url
            data: data_params
            dataType: 'html'
          ).done (data, status, jqXHR) ->
            $('.work_programm_'+kind).html $(jqXHR.responseText).find('.work_programm_'+kind).html()
            form.remove()
            $this.show()
            init_check_valid()

          false

    false
