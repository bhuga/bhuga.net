$ ->
  $('.vibrate').vibrate { speed: 30 }

  $('a').click (event) ->
    $(event.currentTarget).explode {
                            angle: true
                            img:'/images/trexhead.png'
                            centerOn:event.currentTarget
                            interval:2
                            minThrow:500
                            maxThrow:800
                            angle:true
                            num:25
                            explode: false
                            extraWidth:100
                            rotateSpeed:30
                          }
    $(event.currentTarget).explode {
                            angle: true
                            img:'/images/utahraptorhead.png'
                            centerOn:event.currentTarget
                            interval:2
                            minThrow:500
                            maxThrow:800
                            angle:true
                            num:25
                            explode: false
                            extraWidth:200
                            rotateSpeed:30
                          }

  $('a').click ->
    # cache href or its gone in the closure later
    href = this.href
    setTimeout ->
      window.location.href = href
    , 1000
    this.href = null

  disqus_loaded_callback = ->
    console.log "disqus is all done loading!"
    $('span.dsq-comment-footer-reply button').html('ARGUE!')
    $('span.dsq-like button').html('AWESOME!')
    $('button.dsq-button span').html('POST AS...')
    $('a#dsq-like-thread-button span.dsq-toolbar-label').html('THIS IS AWESOME!')

  disqus_loaded = setInterval ->
    if $('#dsq-comments-title').get(0)
      clearInterval disqus_loaded
      disqus_loaded_callback()
  , 100
