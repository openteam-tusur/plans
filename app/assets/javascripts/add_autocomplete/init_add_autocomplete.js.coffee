@init_add_autocomplete = () ->
  input_element = $('.need_autocomplete').autocomplete
    #source: (request, response)->
      #array = eval($(this.element).closest('form').siblings('.autocomplete_data').text())
      #console.log $(this.element)
      #results = $.map array, (item) ->
        #if item.search(new RegExp request.term, 'i') != -1
          #return item
      #response results
      #source: eval($(input_element).closest('form').siblings('.autocomplete_data').text())
    source: []
    minLength: 2

  console.log eval($(input_element).closest('form').siblings('.autocomplete_data').text())
