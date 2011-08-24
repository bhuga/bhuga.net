(
  # Private functions 
  privateFunc = () ->
    console.log "private"

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

  # Public Functions
  methods =
    init: (opts) ->
      $(@).data 'vibrate.speed', opts.speed
      $(@).data 'vibrate.status', false
      $(@).mouseover ->
        $(@).data 'vibrate.status', true
        vibrateLoop.apply @
      $(@).mouseout ->
        $(@).data 'vibrate.status', false
      return

  $.fn.vibrate = (method) ->
    console.log "In vibrate plugin..."
    # Method calling logic
    if methods[method]
      methods[method].apply this, Array.prototype.slice.call arguments, 1
    else if typeof method is 'object' or !method
      methods.init.call what, method for what in this
    else
      $.error "jQuery.vibrate: Method #{ method } does not exist on jQuery.pluginName"
  return
)
