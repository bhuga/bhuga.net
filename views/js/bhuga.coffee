$ ->
  # explode on raptor dropdown
  $('.vibrate').vibrate { speed: 30 }

  $('.explode').click (event) ->
    explosion_defaults =
      interval:2
      minThrow:500
      maxThrow:800
      num:15
      extraWidth:100
      rotateSpeed:30

    trex = $.extend({}, explosion_defaults, { img:'/images/trexhead.png' })
    utahraptor = $.extend({}, explosion_defaults, { img:'/images/utahraptorhead.png' })
    triceratops = $.extend({}, explosion_defaults, { img:'/images/triceratops-skull.png' })

    $(event.currentTarget).explode($.extend(trex, { centerOn:event.currentTarget }))
    $(event.currentTarget).explode($.extend(utahraptor, { centerOn:event.currentTarget }))
    $(event.currentTarget).explode($.extend(triceratops, { centerOn:event.currentTarget }))

  # disqus styling
  disqus_loaded_callback = ->
    $('li[id^="dsq-like"] a').text('AWESOME!')
    $('.dsq-comment-reply').text('ARGUE!')

  disqus_loaded = setInterval ->
    if $('#dsq-comments-title').get(0)
      clearInterval disqus_loaded
      disqus_loaded_callback()
  , 100

  # velociraptor dropdown
  audioSupported = false
  if ($.browser.mozilla && $.browser.version.substr(0, 5) >= "1.9.2" || $.browser.webkit)
    audioSupported = true

  if audioSupported
    raptorAudio = $('<audio id="elRaptorShriek" preload="auto"><source src="/raptor-sound.mp3" /><source src="/raptor-sound.ogg" /></audio>')
    $('body').append(raptorAudio)

  $('#where-am-i').click ->
    $('#dinosaur-hello').slideDown()
    if audioSupported
      $('#elRaptorShriek').get(0).play()

  # swimming plesiosaur
  setTimeout ->
    $('#plesiosaur').swim(
      speed: 10000
      z: 5000
      amplitude: 40
    )
  , 8000

  # pteradactyl
  setTimeout ->
    $('body').pteradactyl()
  , 12000
