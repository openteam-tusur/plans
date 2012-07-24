@init_add_autocomplete = () ->
  $('.need_autocomplete').autocomplete
    source: (request, response)->
      array = eval($(this.element).closest('.form_wrapper').siblings('.disciplines').text())
      results = $.map array, (item) ->
        if item.search(new RegExp request.term, 'i') != -1
          return item
      response results

    minLength: 2
