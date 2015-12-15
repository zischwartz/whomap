
# http://bl.ocks.org/awoodruff/94dc6fc7038eba690f43

# width = 1160
# height = 700
# # invisible map of polygons
# polyCanvas = d3.select('body').append('canvas').attr('width', width).attr('height', height).style('display', 'none')
# # using this div to crop the map; it has messy edges
# container = d3.select('body').append('div').style(
#   'position': 'relative'
#   'width': width - 200 + 'px'
#   'height': height - 200 + 'px'
#   'overflow': 'hidden')
# # canvas for dot map
# dotCanvas = container.append('canvas').attr('width', width).attr('height', height).style(
#   'position': 'absolute'
#   'top': '-100px'
#   'left': '-100px')
# projection = d3.geo.albers().rotate([
#   71.083
#   0
# ]).center([
#   0
#   42.3581
# ]).parallels([
#   40
#   44
# ]).scale(880000).translate([
#   width / 2
#   height / 2
# ])
# path = d3.geo.path().projection(projection)
# polyContext = polyCanvas.node().getContext('2d')
# features = undefined

testPixelColor = (imageData, x, y, w, r, g) ->
  index = (x + y * w) * 4
  imageData.data[index + 0] == r and imageData.data[index + 1] == g

drawPolygon = (feature, context, fill) ->
  coordinates = feature.geometry.coordinates
  context.fillStyle = fill or '#000'
  context.beginPath()
  coordinates.forEach (ring) ->
    ring.forEach (coord, i) ->
      projected = projection(coord)
      if i == 0
        context.moveTo projected[0], projected[1]
      else
        context.lineTo projected[0], projected[1]
      return
    return
  context.closePath()
  context.fill()
  return

# there are faster (or prettier) ways to draw lots of dots, but this works
# drawPixel = (x, y, r, g, b, a) ->
#   dotContext.fillStyle = 'rgba(' + r + ',' + g + ',' + b + ',' + a / 255 + ')'
#   dotContext.fillRect x, y, 1, 1

# d3.json 'blocks.json', (error, blocks) ->
drawBlocks = (blocks, polyContext, path)->
  features = topojson.feature(blocks, blocks.objects.massblocks_central).features
  # draw the polygons with a unique color for each
  i = features.length
  while i--
    r = parseInt(i / 256)
    g = i % 256
    drawPolygon features[i], polyContext, 'rgb(' + r + ',' + g + ',0)'
  # pixel data for the whole polygon map. we'll use color for point-in-polygon tests.
  imageData = polyContext.getImageData(0, 0, width, height)
  # now draw dots
  i = features.length
  while i--
    pop = features[i].properties.POP10 / 2
    # one dot = 2 people
    if !pop
      continue
    bounds = path.bounds(features[i])
    x0 = bounds[0][0]
    y0 = bounds[0][1]
    w = bounds[1][0] - x0
    h = bounds[1][1] - y0
    hits = 0
    count = 0
    limit = pop * 10
    r = parseInt(i / 256)
    g = i % 256
    # test random points within feature bounding box
    while hits < pop - 1 and count < limit
      # we're done when we either have enough dots or have tried too many times
      x = parseInt(x0 + Math.random() * w)
      y = parseInt(y0 + Math.random() * h)
      # use pixel color to determine if point is within polygon. draw the dot if so.
      if testPixelColor(imageData, x, y, width, r, g)
        drawPixel x, y, 0, 153, 204, 255
        # #09c, vintage @indiemaps
        hits++
      count++