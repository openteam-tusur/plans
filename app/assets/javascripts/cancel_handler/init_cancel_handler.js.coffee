@init_cancel_handler = () ->
  $('.cancel').on 'click', ->
    $this = $(this)
    parent = $this.parent()
    parent.find('.add_text').show()
    parent.find('textarea, .submit_link, .cancel').remove()
    if parent.is('form')
      parent.closest('.form_wrapper').siblings('.add_discipline').show()
      parent.parent().off().remove()

    false
