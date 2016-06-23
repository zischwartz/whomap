
d3 = require 'd3'
topojson = require 'topojson'
textures = require 'textures'
convert_countries = require "i18n-iso-countries"
$ = require 'jquery'
pip = require 'point-in-polygon'

brewer = require './brewer.js'

window.dev = {convert_countries, d3, topojson, textures}


width = $(window).width() #960
height = $(window).height() # 580

color = d3.scale.category10()
# color = d3.scale.ordinal().range(brewer.RdBu[9])
# color = d3.scale.ordinal().range(brewer.Spectral[11])
# color = d3.scale.ordinal().range(brewer.RdYlGn[9])
# RdYlGn

projection = d3.geo.mercator().scale((width + 1) / 2 / Math.PI).translate([
  width / 2
  height / 2
]).precision(.1)
path = d3.geo.path().projection(projection)
graticule = d3.geo.graticule()
svg = d3.select('body').append('svg').attr('width', width).attr('height', height)
svg = svg.append("g")

svg.append('rect').attr('class', 'overlay').attr('width', width).attr 'height', height

# svg.append('defs').append('path').datum(type: 'Sphere').attr('id', 'sphere').attr 'd', path
# svg.append('use').attr('class', 'stroke').attr 'xlink:href', '#sphere'
# svg.append('use').attr('class', 'fill').attr 'xlink:href', '#sphere'
# svg.append('path').datum(graticule).attr('class', 'graticule').attr 'd', path



# d3.json 'world-50m.json', (error, world) ->

d3.json 'world-110m.json', (error, world) ->
  if error then throw error
  # d3.csv "population.csv", (error, population) ->
  d3.csv "population.csv", (d) ->
    # coerce to int with +
    d["pop_in_k"] = +d["pop_in_k"]
    d["urban"] = +d["Population living in urban areas (%)"]
    # Population living in urban areas (%)
    return d
  , (err, population)->
    # convert_countries.getName(4, "EN")
    window.population = population
    extent = d3.extent population, (d)-> d["pop_in_k"]
    # log, pow, linear
    # dot_scale = d3.scale.log().domain(extent).range([1, 5])

    m_per_pixel = d3.scale.linear().domain([extent[0]/1000, extent[1]/1000]).range([1, 500])
    window.m_per_pixel =m_per_pixel

    # HAD DELETED THESE, but then there's an error, whaat was I doing six months ago again?
    dot_size_scale = d3.scale.log().domain([extent[1], extent[0]]).range([2, 10]) # more
    dot_radius_scale = d3.scale.linear().domain(extent).range([0.5, 2])

    pop_by_name = {}
    for x in population
      pop_by_name[x['country']]= x

    window.pop_by_name = pop_by_name
    if error then throw error
    
    countries = topojson.feature(world, world.objects.countries).features
    neighbors = topojson.neighbors(world.objects.countries.geometries)
    
    # mash the data (countries) together
    for c in countries
     name = convert_countries.getName(c.id, "EN")
     c["name"] = name
     pop_data = pop_by_name[name]
     c["pop_in_k"] = pop_data?["pop_in_k"]
     c["urban"] = pop_data?["urban"]
     [b1, b2]= path.bounds c
     w = b2[0]-b1[0]
     h = b2[1]-b1[1]
     # @maxRadius, @padding, @width, @height, @autoadd=true)
     max = c["urban"]/10
     padding = 5

     # c["quad"] = new Quad(max, padding, w,h)
     # c["pop_remaining"] = c["pop_in_k"] 



    svg.selectAll('.country').data(countries).enter().insert('path', '.graticule').attr('class', 'country').attr('d', path).each (d,i)->
      console.log i, ':', d
      # console.log path(d)
      # console.log path.bounds d
      # console.log path.area d
      # console.log path.context(d)
      # console.log this

      console.log " "


    .style 'fill', -> return "red"
      # if pop_data
      #   dot_radius = dot_radius_scale pop_data["pop_in_k"]
      #   dot_size = dot_size_scale pop_data["pop_in_k"]
      # else
      #   # console.log d.id, name
      #   dot_size = 15
      #   dot_radius = 0
      # color d.color = d3.max(neighbors[i], (n) ->
      #   countries[n].color
      # ) + 1 | 0
      # circle_texture = textures.circles().radius(dot_radius).size(dot_size).complement().fill(color d.color)
      # svg.call(circle_texture)
      # return circle_texture.url()

    # tooltip!
    svg.selectAll(".country").append("svg:title").text (d)-> "#{d.name}: #{Math.round(d.pop_in_k/1000)}m"


    # legend!
    ticks = dot_radius_scale.ticks(70)
    samples = []
    for t in ticks
      x = 
        r: dot_radius_scale t
        s: dot_size_scale t
        p: Math.round(t/1000)
      samples.push x

    mid = samples[10]
    end = samples[30]
    samples = samples[0...3].concat mid, end
    # console.log samples

    # # (x/5 for x  in[0..4])
    # num_legend_samples = 3
    # # this one shouldn't be linear?
    # leg_size_scale = d3.scale.linear().domain([num_legend_samples, 0]).range(dot_size_scale.range())
    # leg_radius_scale = d3.scale.linear().domain([0, num_legend_samples]).range(dot_radius_scale.range())
    # window.leg_size_scale =leg_size_scale
    # window.leg_radius_scale = leg_radius_scale

    # legend_samples = [0..num_legend_samples]
    legend = svg.selectAll('.legend').data(samples).enter().append('g').attr('class', 'legend').attr('transform', (d, i) ->
      'translate(36,' + (i * 25+600) + ')'
    )
    # # just use d here again
    legend.append('rect').attr('x', 36).attr('width', 36).attr('height', 18).style 'fill', (d)-> 
    #   console.log d
    #   console.log leg_size_scale(d)
      circle_texture = textures.circles().radius(d.r).size(d.s).complement().fill("#d62728")
      svg.call(circle_texture)
      return circle_texture.url()
    #   # color(d)

    legend.append('text').attr('x', 24).attr('y', 9).attr('dy', '.25em').style('text-anchor', 'end').text (d) -> d.p+"m"

    svg.insert('path', '.graticule').datum(topojson.mesh(world, world.objects.countries, (a, b) ->
      a != b
    ))#.attr('class', 'boundary').attr 'd', path


zoomed = ->
  # console.log d3.event.translate
  svg.attr 'transform', 'translate(' + d3.event.translate + ')scale(' + d3.event.scale + ')'
  return

zoom = d3.behavior.zoom().scaleExtent([
  1
  8
]).on('zoom', zoomed)


svg.call(zoom).call zoom.event

d3.select(self.frameElement).style 'height', height + 'px'

# set max radius based on urban population %
# subtract that from total, base it on area!

class Quad 
  constructor: (@maxRadius, @padding, @width, @height, @autoadd=true) ->
    @quadtree = d3.geom.quadtree().extent([
      [0, 0],[@width, @height]
    ])([])
    @searchRadius = @maxRadius * 2
  
  add: (b)=>
    @quadtree.add b

  make: (k) =>
      if typeof k isnt 'number' then throw "Need a number"; return
      bestDistance = i = 0
      while i < k or bestDistance < @padding
        x = Math.random() * @width
        y = Math.random() * @height
        rx1 = x - @searchRadius
        rx2 = x + @searchRadius
        ry1 = y - @searchRadius
        ry2 = y + @searchRadius
        minDistance = @maxRadius
        # minimum distance for this candidate
        @quadtree.visit (quad, x1, y1, x2, y2) ->
          if p = quad.point
            dx = x - (p[0])
            dy = y - (p[1])
            d2 = dx * dx + dy * dy
            r2 = p[2] * p[2]
            if d2 < r2
              return minDistance = 0
              true

            # within a circle
            d = Math.sqrt(d2) - (p[2])
            if d < minDistance
              minDistance = d
          !minDistance or x1 > rx2 or x2 < rx1 or y1 > ry2 or y2 < ry1
          # or outside search radius
        if minDistance > bestDistance
          bestX = x
          bestY = y
          bestDistance = minDistance
        ++i
      best = [
        bestX
        bestY
        bestDistance - @padding
      ]
      if @autoadd
        @add best
      best



window.Quad = Quad



polyCanvas = d3.select("body")
  .append("canvas")
  .attr("width",width)
  .attr("height",height)
  .style("display","none")

polyContext = polyCanvas.node().getContext("2d")