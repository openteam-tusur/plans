@init_publication_variation = () ->
  $('#publication_location'). on 'change', ->
    $this = $(this)
    count_wrapper = $this.parent().siblings('div.integer')
    url_wrapper   = $this.parent().siblings('div.string.optional')
    if $this.val() == 'library'
      count_wrapper.show()
      url_wrapper.hide()
    else
      count_wrapper.hide()
      url_wrapper.show()
