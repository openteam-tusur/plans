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
        textarea = $('<textarea id='+kind+'/>').insertAfter($this)
        textarea.val(work_programm[kind])
        submit = $('<a href="#" class="submit_link">Сохранить</a>').insertAfter(textarea)
        cancel = $('<a href="#" class="cancel">Отмена</a>').insertAfter(submit)
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
            textarea.add(submit).add(cancel).remove()
            $this.show()

          false

    false
