@init_how_to_handlers = () ->
  $('.how_to').on 'click', (evt) ->
    target = $(evt.target)
    if target.is('a')
      $('#'+target.attr('class')).dialog()
      return false
