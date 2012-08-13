addCss = (el, property, amount) ->
  el = $(el)
  current = parseInt(el.css(property))
  el.css(property, current + amount)

vibrateLoop = () ->
  if $(@).data 'vibrate.wiggled'
    addCss(@, 'padding-left', 1)
    addCss(@, 'padding-bottom', 1)
    addCss(@, 'padding-right', -1)
    addCss(@, 'padding-top', -1)
    $(@).data 'vibrate.wiggled', false
  else
    addCss(@, 'padding-left', -1)
    addCss(@, 'padding-bottom', -1)
    addCss(@, 'padding-right', 1)
    addCss(@, 'padding-top', 1)
    $(@).data 'vibrate.wiggled', true
  if $(@).data 'vibrate.status' || $(@).data 'vibrate.wiggled'
    setTimeout ( () =>
      vibrateLoop.apply @
    ),$(@).data('vibrate.speed')

$.fn.vibrate = (opts = { speed: 50}) ->
  el = $(@)
  el.data 'vibrate.speed', opts.speed
  el.data 'vibrate.status', false
  el.on 'vibrate:start', ->
    if !($(@).data 'vibrate.status')
      $(@).data 'vibrate.status', true
      vibrateLoop.apply @
  el.on 'vibrate:stop', ->
    $(@).data 'vibrate.status', false
  return
