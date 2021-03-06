$.fn.pteradactyl = (opts = {}) ->
  @div = $('#pteradactyl')

  height = @.height()
  width = @.width()

  @div.css('top',height + 400)
  @div.css('left',-100)
  @div.show()

  @speed = (opts.speed || 70) # speed in milliseconds
  @offset = (opts.offset || 150) # y-axis offset per frame
  @max = (opts.offset || 1200) # y-axis offset per frame

  @animateFrame = =>
    newPosition = parseInt(@div.css('background-position-y')) + @offset
    @div.css('background-position-y', "#{newPosition}")

  @interval = setInterval @animateFrame, @speed
  setTimeout (=> clearInterval(@interval)), 4000

  @div.animate({top: 0, left: width + 800}, {
    duration: 6000,
    complete: (=> @div.remove() ),
    specialEasing: {
      top: 'easeOutQuint',
      left: 'easeInQuad'
    }
  })
