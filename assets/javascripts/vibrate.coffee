vibrateLoop = () ->
  left   = parseInt $(@).css('padding-left')
  right  = parseInt $(@).css('padding-right')
  top    = parseInt $(@).css('padding-top')
  bottom = parseInt $(@).css('padding-bottom')
  if $(@).data 'vibrate.wiggled'
    $(@).css 'padding-left', left + 1
    $(@).css 'padding-bottom', bottom + 1
    $(@).css 'padding-top', top - 1
    $(@).css 'padding-right', right - 1
    $(@).data 'vibrate.wiggled', false
  else
    $(@).css 'padding-left', left - 1
    $(@).css 'padding-bottom', bottom - 1
    $(@).css 'padding-top', top + 1
    $(@).css 'padding-right', right + 1
    $(@).data 'vibrate.wiggled', true
  if $(@).data 'vibrate.status' || $(@).data 'vibrate.wiggled'
    setTimeout ( () =>
      vibrateLoop.apply @
    ),$(@).data('vibrate.speed')

$.fn.vibrate = (opts = { speed: 50}) ->
  $(@).data 'vibrate.speed', opts.speed
  $(@).data 'vibrate.status', false
  $(@).mouseover ->
    $(@).data 'vibrate.status', true
    vibrateLoop.apply @
  $(@).mouseout ->
    $(@).data 'vibrate.status', false
  return
