$.fn.show_target = (target) ->
  $('.toc_no_selected').hide()
  $('.selected', '.toc').removeClass('selected')
  $('a[href='+target+']', $('.toc')).parent().addClass('selected')
  target_item = $(target)
  dump = target_item.attr('id')
  target_item.attr('id', '')
  window.location.hash = target
  target_item.attr('id', dump)
  this.hide()
  $(target_item).slideDown()

@init_toc_navigation = () ->
  target = window.location.hash
  items = $('#toc>li').hide()
  items.show_target(target) if target

  $('.toc').click (context)->
    if $(context.target).is('a')
      $(context.target).parent().addClass('selected')
      target = $(context.target).attr('href')
      items.show_target(target) unless $(target).is(':visible')
      false

