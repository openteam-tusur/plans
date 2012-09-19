@init_history = () ->
  $('.show_more').on 'click', ->
    history_container = $('.message_history')
    last_visible = $('.visible', history_container).last()
    next_items = last_visible.nextAll().slice(0, 3)

    if next_items.length
      next_items.toggleClass('hide visible').slideDown()

      if next_items.nextAll().length < 1
        $(this).hide()

    false
