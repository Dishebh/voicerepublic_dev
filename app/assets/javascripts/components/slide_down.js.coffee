attribute = 'data-slide-down'
scroll = 'data-slide-down-scroll'
action = 'data-slide-down-action'

enableFields = (element, selector, scrollTo, actionF) ->
  source = $(element)
  target = $(selector)

  source.click (e) ->
    targetStateOld = !target.hasClass 'slide-down-close'

    if targetStateOld
      closeContent target
    else
      openContent target, scrollTo

  openContent = (target,scrollTo) ->
    height = target.find('.slide-down-content').outerHeight()
    target.removeClass 'slide-down-close'
    target.height height
    if scrollTo
      $('html,body').animate
        scrollTop: target.offset().top, 500
  closeContent = (target) ->
    target.removeAttr('style')
    target.addClass('slide-down-close')

$("*[#{attribute}]").each (index, element) ->
  value    = $($(element).attr(attribute))
  scrollTo = $($(element).attr(scroll))
  actionF   = $($(element).attr(action))
  enableFields element, value, scrollTo, actionF