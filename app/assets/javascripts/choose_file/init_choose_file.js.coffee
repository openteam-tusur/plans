@init_choose_file = () ->
  link = $('.choose_file')
  wrapper = link.parent()

  link.click ->
    params = link.attr('params')
    dialog = link.create_or_return_dialog('elfinder_picture_dialog')
    input  = link.parent().find('input')
    origin_id = input.attr('id')

    dialog.attr('id_data', origin_id)
    dialog.load_iframe(params)

    input.change ->
      file_url = input.val()
      file_name = file_url.match(/([^\/.]+)(\.(.{3}))?$/)
      remove_file(link, input, wrapper, file_url)
      input.unbind('change')

    false

remove_file = (link, input, wrapper, file_url) ->
  link.hide()
  wrapper.prepend('<a href='+file_url+' class="link">Скачать файл</a><a href="#" class="remove_file link">Удалить</a>')
  wrapper.find('.remove_file').on 'click', ->
    input.val('')
    wrapper.find('.link').remove()
    link.show()
    false

