require "set"

module GeohashCr::Proximity
  extend self

  def in_circle_check(latitude, longitude, centre_lat, centre_lon, radius)
    x_diff = longitude - centre_lon
    y_diff = latitude - centre_lat

    return true if (x_diff ** 2) + (y_diff ** 2) <= (radius ** 2)

    false
  end

  def get_centroid(latitude, longitude, height, width)
    y_cen = latitude + (height / 2)
    x_cen = longitude + (width / 2)

    [x_cen, y_cen]
  end

  def convert_to_latlon(y, x, latitude, longitude)
    pi = Math::PI

    earth_radius = 6371000

    lat_diff = (y / earth_radius) * (180 / pi)
    lon_diff = (x / earth_radius) * (180 / pi) / Math.cos(latitude * pi/180)

    final_lat = latitude + lat_diff
    final_lon = longitude + lon_diff

    [final_lat, final_lon]
  end

  def create_geohash(latitude, longitude, radius, precision, georaptor_flag = false, minlevel = 1, maxlevel = 12)
    x = 0.0
    y = 0.0

    points = Array(Float32).new
    geohashes = Array(Float32).new

    grid_width = [5009400.0, 1252300.0, 156500.0, 39100.0, 4900.0, 1200.0, 152.9, 38.2, 4.8, 1.2, 0.149, 0.0370]
    grid_height = [4992600.0, 624100.0, 156000.0, 19500.0, 4900.0, 609.4, 152.4, 19.0, 4.8, 0.595, 0.149, 0.0199]

    height = (grid_height[precision - 1]) / 2
    width = (grid_width[precision - 1]) / 2

    lat_moves = (radius / height).ceil # 4
    lon_moves = (radius / width).ceil  # 2

    (0...lat_moves).each do |i|
      temp_lat = y + height * i
      (0...lon_moves).each do |j|
        temp_lon = x + width * j

        if in_circle_check(temp_lat, temp_lon, y, x, radius)
          x_cen, y_cen = get_centroid(temp_lat, temp_lon, height, width)

          lat, lon = convert_to_latlon(y_cen, x_cen, latitude, longitude)
          points += [[lat, lon]]
          lat, lon = convert_to_latlon(-y_cen, x_cen, latitude, longitude)
          points += [[lat, lon]]
          lat, lon = convert_to_latlon(y_cen, -x_cen, latitude, longitude)
          points += [[lat, lon]]
          lat, lon = convert_to_latlon(-y_cen, -x_cen, latitude, longitude)
          points += [[lat, lon]]
        end
      end
    end

    points.each { |point| geohashes.concat([GeohashCr.encode(point[0], point[1], precision)]) }

    if georaptor_flag
      georaptor_out = compress(::Set.new(geohashes), minlevel, maxlevel)
      return georaptor_out.to_a.join(',')
    else
      return ::Set.new(geohashes).to_a.join(',')
    end
  end

  def get_combinations(str)
    base32 = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k', 'm', 'n', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    array = Array(String).new
    base32.each { |i| array.push(str + i) }
    return array
  end

  def compress(geohashes, minlevel = 1, maxlevel = 12)
    # binding.pry

    deletegh = Array(String).new
    final_geohashes = Array(String).new
    flag = true
    final_geohashes_size = 0

    # Input size less than 32
    if geohashes.size == 0
      print("No geohashes found!")
      return false
    end

    while flag
      final_geohashes.clear
      deletegh.clear

      geohashes.each do |geohash|
        geohash_length = geohash.size

        # Compress only if geohash length is greater than the min level
        if geohash_length >= minlevel
          # Get geohash to generate combinations for
          # Remove last character of geohash
          part = geohash.rchop

          # Proceed only if not already processed
          if !deletegh.to_set.includes?(part) && !deletegh.to_set.includes?(geohash)
            # Generate combinations
            combinations = get_combinations(part)

            # If all generated combinations exist in the input set
            if combinations.to_set.subset?(geohashes.to_set)
              # Add part to temporary output
              final_geohashes.push(part)
              # Add part to deleted geohash set
              deletegh.push(part)

              # Else add the geohash to the temp out and deleted set
            else
              deletegh.push(geohash)

              # Forced compression if geohash length is greater than max level after combination check failure
              if geohash_length >= maxlevel
                final_geohashes.push(geohash[0, maxlevel])
              else
                final_geohashes.push(geohash)
              end
            end

            # Break if compressed output size same as the last iteration
            if final_geohashes_size == final_geohashes.size
              flag = false
            end
          end
        end
      end

      final_geohashes_size = final_geohashes.size
      geohashes.clear

      # Temp output moved to the primary geohash set
      geohashes = geohashes | final_geohashes
    end

    geohashes
  end
end
