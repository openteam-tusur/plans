@init_semester_visibility_toggler = () ->
  $('.collapsed_item').hide()
  $($('.collapsed_item')[0]).show()

  $('li>h3'). on 'click', ->
    $('.collapsed_item:visible').slideToggle()

    unless (items = $(this).siblings('.collapsed_item')).is(':visible')
      items.slideToggle()
