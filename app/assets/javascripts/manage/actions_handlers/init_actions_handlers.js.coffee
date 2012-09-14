@init_actions_handlers = () ->
  $('.actions').on 'click', (evt) ->
    target = $(evt.target)

    if target.is('a')
      dialog = $('#'+target.attr('class'))
      dialog.dialog
        buttons:
          'Отменить': ->
            $(this).dialog('close')

      return false
