@init_cancel_handler = () ->
  $('.cancel_link').on 'click', ->
    $this = $(this)
    parent = $this.closest('form')
    parent.siblings('.add_text').show()
    parent.parent().siblings('.add_discipline').show()
    parent.remove()

    false
