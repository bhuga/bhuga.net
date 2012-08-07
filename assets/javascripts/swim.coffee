###
 make something swim across the screen. marquee is so 1995.
###

class Swimmer
  constructor: (@opts, what) ->
    defaults =
      # wait this long before starting
      delay: 0,
      # how long it takes to swim across the screen, ms
      speed: 10000,
      # amplitude of up-down
      amplitude: 1,
      # what z-index to throw on(default setting throws it over a jquery.ui dialog overlay--but behind modal dialog)
      z: 1001,
      # what's swimming
      swimmer: what,
      # starting bottom
      bottom: -60
      # starting left
      left: -150
    @options = $.extend({}, defaults, @opts)
    @swimmer = @options.swimmer

  swim: () ->
    setTimeout(() =>
      @swimNow()
    , @options.delay)

  swimNow: () ->
    @swimmer.css('left',@options.left)
    @swimmer.css('bottom',@options.bottom)
    @swimmer.css('z-index',@options.z)
    @swimmer.show()
    target =
      left: $(window).width() + 150
    @bob(parseInt(@swimmer.css('bottom')))
    @swimmer.animate target, @options.speed, () =>
      @finished = true

  bob: (start) ->
    return if @finished
    current = parseInt(@swimmer.css('bottom'))
    if current < start
      target = { bottom: start + @options.amplitude }
    else
      target = { bottom: start - @options.amplitude }
    @swimmer.animate target, {
      queue: false
      duration: 1000
      complete: () =>
        @bob(start) }

$.fn.swim = (opts) ->
  swimmer = new Swimmer opts, this
  swimmer.swim()
