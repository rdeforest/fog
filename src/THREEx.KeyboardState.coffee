THREEx = THREEx or {}

class THREEx.KeyboardState
  constructor: ->
    # to store the current state
    @keyCodes  = {}
    @modifiers = {}
    # create callback to bind/unbind keyboard events
    self       = this

    @_onKeyDown = (event) ->
      self._onKeyChange event, true
      return

    @_onKeyUp = (event) ->
      self._onKeyChange event, false
      return

    # bind keyEvents
    document.addEventListener 'keydown', @_onKeyDown
    document.addEventListener 'keyup',   @_onKeyUp

# To stop listening of the keyboard events

  destroy: ->
    # unbind keyEvents
    document.removeEventListener 'keydown', @_onKeyDown
    document.removeEventListener 'keyup',   @_onKeyUp
    return

  @MODIFIERS = [
      'shift'
      'ctrl'
      'alt'
      'meta'
    ]

  @ALIAS =
    'left':     37
    'up':       38
    'right':    39
    'down':     40
    'space':    32
    'pageup':   33
    'pagedown': 34
    'tab':      9

# to process the keyboard dom event

  _onKeyChange: (event, pressed) ->
    # update this.keyCodes
    keyCode = event.keyCode
    @keyCodes[keyCode] = pressed

    # update this.modifiers
    @modifiers['shift'] = event.shiftKey
    @modifiers['ctrl']  = event.ctrlKey
    @modifiers['alt']   = event.altKey
    @modifiers['meta']  = event.metaKey
    return

# query keyboard state to know if a key is pressed of not
#
# @param {String} keyDesc the description of the key. format : modifiers+key e.g shift+A
# @returns {Boolean} true if the key is pressed, false otherwise

  pressed: (keyDesc) ->
    for key in keyDesc.split('+')
      pressed = undefined

      if THREEx.KeyboardState.MODIFIERS.indexOf(key) != -1
        pressed = @modifiers[key]
      else if Object.keys(THREEx.KeyboardState.ALIAS).indexOf(key) != -1
        pressed = @keyCodes[THREEx.KeyboardState.ALIAS[key]]
      else
        pressed = @keyCodes[key.toUpperCase().charCodeAt(0)]

      if !pressed
        return false

    true
