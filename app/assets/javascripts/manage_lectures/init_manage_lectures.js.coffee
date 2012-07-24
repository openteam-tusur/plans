handle_adding = ->
  $('.add_lecture').on 'ajax:success', (event, data, status, xhr) ->
    $this = $(this)
    form_wrapper = $this.siblings('.form_wrapper')

    form_wrapper.html(data)

    form_wrapper.on 'ajax:success', (event, data, status, xhr) ->
      data = $(data)

      if data.find('input').length
        form_wrapper.html(data)
      else
        data.insertBefore(form_wrapper)
        form_wrapper.off().html('')
        handle_editing()
        handle_deleting()

handle_editing = ->
  $('.edit_lecture').on 'ajax:success', (event, data, status, xhr) ->
    $this = $(this)
    lecture_wrapper = $this.parent()

    lecture_wrapper.html(data)

    lecture_wrapper.on 'ajax:success', (event, data, status, xhr) ->
      data = $(data)

      if data.find('input').length
        lecture_wrapper.html(data)
      else
        lecture_wrapper.html(data)
        handle_deleting()

handle_deleting = ->
  $('.delete_lecture').on 'ajax:success', (event, data, status, xhr) ->
    $(this).parent().remove()

@init_manage_lectures = ->
  handle_adding()
  handle_editing()
  handle_deleting()
