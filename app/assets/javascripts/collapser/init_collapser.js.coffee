@init_collapser = () ->
  collapsibles = $('.collapsible')
  collapsibles.on 'click', ->
    link = $(this)

    return false if link.hasClass('process')

    link.addClass('process')
    wrapper = link.next('.collapsible_wrapper')

    wrapper.slideToggle ->
      link.toggleClass('opened').removeClass('process')

    false

  $('.toc').on 'click', ->
    $this = $(this)

    return false if $this.hasClass('process')
    $this.addClass('process')
    if collapsibles.hasClass('opened')
      collapsibles.removeClass('opened').removeClass('process')
      $('.collapsible_wrapper').slideUp ->
        $this.removeClass('process')
    else
      collapsibles.removeClass('opened').removeClass('process')
      $('.collapsible_wrapper').slideDown ->
        $this.removeClass('process')
      collapsibles.addClass('opened')
    false
