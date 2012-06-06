@init_add_programm = () ->
  link = $('.add_link')
  wrapper = $('.programm')

  wrapper.on 'ajax:success', (event, response, status)->
    wrapper.html(response)
    init_choose_file()

  link.click ->
    $.ajax
      url: link.attr('data-url')
      type: 'GET'
      success: (response, status) ->
        wrapper.html(response)
        init_choose_file()

    false
