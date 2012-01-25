$.fn.pteradactyl = (opts = {}) ->
  @div = $('<div class=pteradactyl></div>')
  @div.css('background-image','url("/images/pteradactyl.png")')
  @div.css('position','fixed')
  @div.css('height','150px')
  @div.css('width','350px')
  @div.css('z-index',10)
  @div.css('top',-400)
  @div.css('left',-400)
  @.append(@div)

  @speed = (opts.speed || 70) # speed in milliseconds
  @offset = (opts.offset || 150) # y-axis offset per frame
  @max = (opts.offset || 1200) # y-axis offset per frame

  @animateFrame = =>
    newPosition = parseInt(@div.css('background-position-y')) + @offset
    @div.css('background-position-y', "#{newPosition}")

  @interval = setInterval @animateFrame, @speed
  setTimeout (=> console.log(@interval) ; clearInterval(@interval)), 2300
  height = $(window).height()
  width = @.width()
  @div.animate({top: height + 100, left: width + 400}, {
    duration: 6000,
    complete: (=> @div.remove() ),
    specialEasing: {
      top: 'easeOutQuad',
      left: 'linear'
    }
  })
