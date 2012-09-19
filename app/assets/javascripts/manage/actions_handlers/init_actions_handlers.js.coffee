@init_actions_handlers = () ->
  $('.actions').on 'click', (evt) ->
    target = $(evt.target)

    if target.is('a')
      dialog = $('#'+target.attr('class'))
      dialog.dialog
        width: 450
        modal: true
        title: 'Отправка рабочей программы'
        buttons:
          'Отменить': ->
            $(this).dialog('close')

      return false
