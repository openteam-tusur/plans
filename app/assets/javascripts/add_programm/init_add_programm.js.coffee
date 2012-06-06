@init_add_programm = () ->
  wrapper = $('.programm')

  wrapper.on 'ajax:success', (event, response, status)->
    wrapper.html(response)
    init_choose_file()
    vfs_wrapper = wrapper.find('.add_file_wrapper')
    remove_file(vfs_wrapper, vfs_wrapper.find('input'), $('<a href="#" class="choose_file">Выбрать файл</a>'))
