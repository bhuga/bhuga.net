$ ->
  $('.vibrate').vibrate { speed: 30 }

  $('a').click (event) ->
    console.log event.currentTarget
    $(event.currentTarget).imgExplosion {
                            angle: true 
                            img:'/images/trexhead.png'
                            centerOn:event.currentTarget
                            interval:2
                            minThrow:500
                            maxThrow:1300
                            angle:true
                            num:40
                            explode: false
                            extraWidth:100
                            rotateSpeed:30
                          }
    $(event.currentTarget).imgExplosion {
                            angle: true 
                            img:'/images/utahraptorhead.png'
                            centerOn:event.currentTarget
                            interval:2
                            minThrow:500
                            maxThrow:1300
                            angle:true
                            num:40
                            explode: false
                            extraWidth:200
                            rotateSpeed:30
                          }

  $('a').click ->
    console.log('click function: href: ' + this.href)
    # cache href
    href = this.href
    setTimeout ->
      console.log('time to move pages!')
      # window.location.href = href
    , 1000
    this.href = null
