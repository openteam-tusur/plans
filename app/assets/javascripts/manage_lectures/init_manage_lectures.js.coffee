handle_adding = ->
  $('.add_lecture').on 'ajax:success', (event, data, status, xhr) ->
    $this = $(this)
    number = $this.attr('data-number')
    form_wrapper = $('.semester_' + number + '_form_wrapper')
    table = $('.lectures')

    $this.off()
    form_wrapper.html(data)
    handle_new_lecture_cancel()

    form_wrapper.on 'ajax:success', (event, data, status, xhr) ->
      data = $(data)

      if data.find('input').length
        form_wrapper.html(data)
      else
        table.replaceWith(data)
        handle_adding()
        handle_editing()
        handle_deleting()

handle_editing = ->
  $('.edit_lecture').on 'ajax:success', (event, data, status, xhr) ->
    $this = $(this)
    lecture_wrapper = $this.closest('tr')
    table = $('.lectures')

    lecture_wrapper.html(data)

    lecture_wrapper.on 'ajax:success', (event, data, status, xhr) ->
      data = $(data)

      if data.find('input').length
        lecture_wrapper.html(data)
      else
        table.replaceWith(data)
        handle_adding()
        handle_editing()
        handle_deleting()

handle_deleting = ->
  $('.delete_lecture').on 'ajax:success', (event, data, status, xhr) ->
    table = $('.lectures')

    table.replaceWith(data)
    handle_adding()
    handle_editing()
    handle_deleting()

handle_new_lecture_cancel = ->
  $('.new_lecture_cancel').on 'click', ->
    $(this).closest('tr').html('')

    false

@init_manage_lectures = ->
  handle_adding()
  handle_editing()
  handle_deleting()
