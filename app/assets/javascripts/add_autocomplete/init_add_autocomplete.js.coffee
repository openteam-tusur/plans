@init_add_autocomplete = () ->
  input_element = $('.need_autocomplete').autocomplete
    source: (request, response)->
      array = eval($(this.element).closest('form').siblings('.autocomplete_data').text())
      results = $.map array, (item) ->
        if (item.value.search(new RegExp request.term, 'i') != -1) || (request.term.match(/\s/))
          return item
      response results
    minLength: 2
    select: (event, ui) ->
      form = $(event.target).closest('form')
      $('#person_post', form).val(ui.item.post)
      $('#person_academic_degree', form).val(ui.item.academic_degree)
      $('#person_academic_rank', form).val(ui.item.academic_rank)
