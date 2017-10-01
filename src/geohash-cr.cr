require "./geohash-cr/*"

module GeohashCr
  def decode(geohash)
    latlng = [[-90.0, 90.0], [-180.0, 180.0]]
    is_lng = 1
    geohash.downcase.scan(/./) do |c|
      BITS.each do |mask|
        latlng[is_lng][(BASE32.index(c) & mask)==0 ? 1 : 0] = (latlng[is_lng][0] + latlng[is_lng][1]) / 2
        is_lng ^= 1
      end
    end
    latlng.transpose
  end

  def encode(latitude, longitude, precision=12)
    latlng = [latitude, longitude]
    points = [[-90.0, 90.0], [-180.0, 180.0]]
    is_lng = 1
    (0...precision).map {
      ch = 0
      5.times do |bit|
        mid = (points[is_lng][0] + points[is_lng][1]) / 2
        points[is_lng][latlng[is_lng] > mid ? 0 : 1] = mid
        ch |=  BITS[bit] if latlng[is_lng] > mid
        is_lng ^= 1
      end
      BASE32[ch,1]
    }.join
  end

  def neighbors(geohash)
    [[:top, :right], [:right, :bottom], [:bottom, :left], [:left, :top]].map{ |dirs|
      point = adjacent(geohash, dirs[0])
      [point, adjacent(point, dirs[1])]
    }.flatten
  end

  def parent_neighbors(geohash)
    parent = geohash[0...-1]
    lat1, lng1 = decode(geohash).reduce { |a,b| [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2]  }
    lat2, lng2 = decode(parent).reduce { |a,b| [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2]  }

    top, top_right, right, bottom_right, bottom, bottom_left, left, top_left = neighbors(parent)

    return [top, top_right, right, parent] if lat1 > lat2 and lng1 > lng2
    return [top, top_left, left, parent] if lat1 > lat2
    return [bottom, bottom_right, right, parent] if lng1 > lng2
    return [bottom, bottom_left, left, parent]
  end

  def adjacent(geohash, dir)
    base, lastChr = geohash[0...-1], geohash[-1,1]
    type = (geohash.length % 2)==1 ? :odd : :even
    if BORDERS[dir][type].include?(lastChr)
      base = adjacent(base, dir)
    end
    base + BASE32[NEIGHBORS[dir][type].index(lastChr),1]
  end

  BITS = [0x10, 0x08, 0x04, 0x02, 0x01]
  BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"

  NEIGHBORS = {
    right: { even: "bc01fg45238967deuvhjyznpkmstqrwx", odd: "p0r21436x8zb9dcf5h7kjnmqesgutwvy" },
    left: { even: "238967debc01fg45kmstqrwxuvhjyznp", odd: "14365h7k9dcfesgujnmqp0r2twvyx8zb" },
    top: { even: "p0r21436x8zb9dcf5h7kjnmqesgutwvy", odd: "bc01fg45238967deuvhjyznpkmstqrwx" },
    bottom: { even: "14365h7k9dcfesgujnmqp0r2twvyx8zb", odd: "238967debc01fg45kmstqrwxuvhjyznp" }
  }

  BORDERS = {
    righ: { even: "bcfguvyz", odd: "prxz" },
    left: { even: "0145hjnp", odd: "028b" },
    top: { even: "prxz", odd: "bcfguvyz" },
    bottom: { even: "028b", odd: "0145hjnp" }
  }
end
