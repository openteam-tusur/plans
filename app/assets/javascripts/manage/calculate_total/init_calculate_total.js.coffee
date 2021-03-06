calculate_exam_score = () ->
  $('.examination_questions').each (index, item) ->
    sum = 0
    $('tbody tr td:nth-child(2)', item).each (index, td) ->
      sum += Number($(td).html())

    $(item).parent().prev("table").find('.examination_total').html(sum)

calculate_total_rating_items_score = () ->
  kinds = ['max_begin_1kt', 'max_1kt_2kt', 'max_2kt_end', 'total_score']
  $('.rating_items').each (index, item) ->
    sums = {
      max_begin_1kt: 0
      max_1kt_2kt: 0
      max_2kt_end: 0
      total_score: 0
    }

    for k in kinds
      $('.'+k, item).each (index, cell) ->
        sums[k] += Number($(cell).html())
      $('.target_'+k, item).html(sums[k])

      if prev
        $('.increasing_'+k, item).html(sums[k] + Number($('.increasing_'+prev, item).html()))
      else
        $('.increasing_'+k, item).html(sums[k])
      prev = k

    result = Number($('.target_total_score', item).html())
    result += Number($('.examination_total', item).html()) if $('.examination_total').length
    $('.increasing_total', item).html(result)

calculate_hours = () ->
  $('.exercises').each (index, table) ->
    table = $(table)
    total = Number(table.find('.rup_hours td span').html())
    total_hours_wrapper = table.find('.total_hours td')
    sum = 0
    table.find('.hours').each (index, item) ->
      sum += Number($(item).html())
    total_hours_wrapper.find('span').html(sum)
    if sum != total
      total_hours_wrapper.addClass('warning')
    else
      total_hours_wrapper.removeClass('warning')

@init_calculate_total = () ->
  calculate_hours()
  calculate_exam_score()
  calculate_total_rating_items_score()
