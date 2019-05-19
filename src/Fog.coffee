class FogApp
  constructor: (@window) ->
    {@document} = @window

    @size         = 16

    @running      = true

    if @window.WebGLRenderingContext
      @renderer = new (THREE.WebGLRenderer)
    else
      @renderer = new (THREE.CanvasRenderer)

    @renderer.setSize @window.innerWidth, @window.innerHeight

    @init()

    @document.body.appendChild @renderer.domElement

  # Stuff that also gets reset by the reset button
  init: ->
    @scene        = new THREE.Scene

    @lastFrameMS  = null

    @_volumes =
      [1..@size].map (z) ->
        [1..@size].map (y) ->
          [1..@size].map (x) ->
            @makeVolume {x, y, z}

    @camera = new THREE.PerspectiveCamera 75, @window.innerWidth / @window.innerHeight, 0.1, 1000000

    setPosition @camera,      x: 0, y: 0, z: 600
    setPosition @arrowHelper, x: 0, y: 0, z: 0

    @scene.add mesh for {mesh} in @particles

    #@scene.add @arrowHelper

    return @

  neighborhood: (prevPlane, plane, nextPlane, x, y) ->
    [x0, y0] = [x, y].map (n) -> Math.max n, 0
    [x1, y1] = [x, y].map (n) -> n + 1

    rSlice = (plane) -> plane[y0..y1]
    cSlice = (row)   -> row[x0..x1]

    [prevPlane, plane, nextPlane]
      .map (p) -> cSlice rSlice p

  volumes: ->
    for plane, z in @_volumes
      for row, y in plane
        for cell, x in row
          {x, y, z, cell}

  permute: ->
    deltaT = 1/(@msPerFrame or 1)

    for v in @volumes()

    return @

  handleKeypresses: ->
    op.call @ for key, op of @hotKeys when @keyboard.pressed key

    @cooldown-- if @cooldown > 0

  computeMeanVelocity: ->
    total = 0
    for p in @particles
      total += p.velocity.mag()

    total / @numParticles

  computeCenterOfMass: ->
    centerOfMass = [0, 0, 0]
    totalMass    = 0

    for p in @particles
      for axis, i in ['x', 'y', 'z']
        centerOfMass[i] += p.position[axis] * p.mass

      totalMass       += p.mass

    Vector.fromArray centerOfMass
      .scaled (1 / totalMass)

  updateView: ->
    {x, y, z} = @camera.position
    if false
      {x: x2, y: y2, z: z2} = @computeCenterOfMass().plus @delta
    else
      {x: x2, y: y2, z: z2} = @sun.position
   
    x += (x2 - x) * @cameraFactor
    y += (y2 - y) * @cameraFactor
    z += (z2 - z) * @cameraFactor

    z += @largestSize * 40

    setPosition @camera,      {x, y, z}
    setPosition @arrowHelper, {x, y, z}

    zOffset = if @showArrow then -3 else 600
    @arrowHelper.position.x += zOffset

    direction = new THREE.Vector3 x, y, z
    @arrowHelper.setDirection direction.normalize()
    @arrowHelper.setLength    direction.length()

    @msPerFrame = (now = Date.now()) - @lastFrameMS
    @lastFrameMS = now

    return @

  start: ->
    @running = true
    @render()

  stop: ->
    @running = false

  render: ->
    if @running
      requestAnimationFrame => @render()
      @handleKeypresses()
      @move()
      @updateView()
      @renderer.render @scene, @camera

    return @

(app = new GravApp window)
  .start()

reInit = (->
    @numParticles = (@getValueOf 'numparticles')
    @gravConstant = (@getValueOf 'gravstr'     ) / 100
    @maxSize      = (@getValueOf 'maxSize'     )

    #@particles = []
    #@scene = new THREE.Scene
    @init()
    return @
  ).bind app
