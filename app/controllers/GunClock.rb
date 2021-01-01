#<sample>
#gunClock = GunClock.new(15)
#gunClockString = gunClock.toString()

require "date"

class GunClock
  @@gunClock = []

  def self.putGunClock1Chara(x, y, c)
    @@gunClock[y][x] = c
  end

  class Cast
    def initialize(image)
      @image = image
    end

    def display(x, y)
      _x = (x * 2) - ( @image[0].length / 2 )
      _y = y - (@image.length / 2 )
      for i in 0..(@image.length-1) do
        for j in 0..(@image[i].length-1) do
          c = @image[i][j,1]
          if c != "*" and ( _x + j ) >=0 and ( _y + i) >=0 then
#            @gunClock[_y+i][_x+j] = c
            GunClock.putGunClock1Chara( _x+j, _y+i, c)
          end
        end
      end
    end

  end  #of class Cast


  def initialize(gunClockSize,gunClockTime="")
    @gunClockSize = gunClockSize
    @gunClockTime = gunClockTime
    @@gunClock = Array.new(gunClockSize) { Array.new(gunClockSize*2) }
    @centerX = @gunClockSize / 2
    @centerY = @gunClockSize / 2
    for y in 0..(@@gunClock.length-1) do
      for x in 0..(@@gunClock[y].length-1) do
#        @@gunClock[y][x]= " "
        GunClock.putGunClock1Chara( x, y, " ")
      end
    end

    createGunClock()

  end

  def hourToRadian(h, m)
    return Math::PI * ( 90.0 - ( (h%12) + m/60 ) * 30 ) /180.0
  end

  def minuteToRadian(m, s)
    return Math::PI * ( 90.0 - ( m + s/60 ) * 6 ) /180.0
  end

  def digitalRadian(h, m, s)
    hRadian = hourToRadian(h, m)
    mRadian = minuteToRadian(m, s)
    aveRadian = (hRadian + mRadian) /2
    if ( hRadian > mRadian && ( hRadian - mRadian ) < Math::PI ) \
     ||( mRadian > hRadian && ( mRadian - hRadian ) < Math::PI ) then
      return aveRadian + Math::PI
    else
      return aveRadian
    end
  end



  def getTime
    if @gunClockTime == "" then
      ENV['TZ'] = 'Asia/Tokyo'
      now = DateTime.now
      return now.hour, now.min, now.sec
    else
      return @gunClockTime.sub(/(..):../, '\1').to_i, @gunClockTime.sub(/..:(..)/, '\1').to_i, 0
    end
  end

  def wakuDisplay(waku)
    for i in 0.step(360,30) do
      if ( i % 90 == 0 ) then
        next
      end
      radian = ( i * 2 * Math::PI ) / 360
      wakuXdiff = @gunClockSize / 2 * Math.cos(radian)
      wakuYdiff = @gunClockSize / 2 * Math.sin(radian)

      if ( wakuXdiff >= 0 ) then
        wakuX = @centerX + wakuXdiff.floor
      else
        wakuX = @centerX + wakuXdiff.ceil
      end

      if ( wakuYdiff >= 0 ) then
        wakuY = @centerY + wakuYdiff.floor
      else
        wakuY = @centerY + wakuYdiff.ceil
      end

      waku.display(wakuX, wakuY)

    end
  end

  def numDisplay(num3, num6, num9, num12)
    num3.display(@gunClockSize - 1, @centerY)
    num6.display(@centerX, @gunClockSize - 1)
    num9.display(0, @centerY)
    num12.display(@centerX, 0)
  end

  def longHandDisplay(longHand)
    for i in 0..(@gunClockSize*2/3/2-1) do
      longHandX = @centerX + (((@inuX - @centerX) * i) / (@gunClockSize*2/3/2))
      longHandY = @centerY + (((@inuY - @centerY) * i) / (@gunClockSize*2/3/2))
      longHand.display(longHandX, longHandY)
    end
  end

  def shortHandDisplay(shortHand)
    for i in 0..(@gunClockSize*5/6/2-1) do
      shortHandX = @centerX + (((@gunmanX - @centerX) * i) / (@gunClockSize*5/6/2))
      shortHandY = @centerY + (((@gunmanY - @centerY) * i) / (@gunClockSize*5/6/2))
      shortHand.display(shortHandX, shortHandY)
    end
  end


  def digitalTimeDisplay(h, m, s)
    myTime = sprintf("%02d:%02d", h, m)
    digitalTime = Cast.new([
      "_______",
      "|" + myTime + "|",
      "~~~~~~~"
    ])
    digitalTimeRadian = digitalRadian(h, m, s)
    digitalTime.display(
      @centerX + (Math.cos(digitalTimeRadian) * @gunClockSize/2 * 1/2),
      @centerY - (Math.sin(digitalTimeRadian) * @gunClockSize/2 * 1/2)
    )
  end

  def toString
    ret = ""
    for y in 0..(@@gunClock.length-1) do
      for x in 0..(@@gunClock[y].length-1) do
        ret+=@@gunClock[y][x]
      end
      ret+="\n"
    end
    return ret
  end

  def createGunClock()

    gunman = Cast.new([
      "** __ *", 
      " _|__|_",
      "b (@@) ",
      " V|~~|>",
      "* //T| "
    ])

    inu = Cast.new([
      "__AA  **",
      "| 6 |__P",
      "~~|    l",
      "*/_/~l_l"
    ])

    (hour, minute, second) = getTime()

    @gunmanX = @centerX + Math.cos(hourToRadian(hour, minute)) * (@gunClockSize * 2/3/2)
    @gunmanY = @centerY - Math.sin(hourToRadian(hour, minute)) * (@gunClockSize * 2/3/2)
    @inuX = @centerX + Math.cos(minuteToRadian(minute, second)) * (@gunClockSize * 4/5/2)
    @inuY = @centerY - Math.sin(minuteToRadian(minute, second)) * (@gunClockSize * 4/5/2)

    wakuDisplay(Cast.new(["+"]))
    numDisplay(Cast.new(["3"]),Cast.new(["6"]), Cast.new(["9"]), Cast.new(["12"])) 
    longHandDisplay(Cast.new(["##"]))
    shortHandDisplay(Cast.new(["::"]))

    inu.display(@inuX, @inuY)
    gunman.display(@gunmanX, @gunmanY)

    digitalTimeDisplay( hour, minute, second)

  end

end
