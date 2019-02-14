express = require 'express'
router  = express.Router()

router.get '/', (req, res, next) ->
  res.send 'respond with a resource'
  return

module.exports = router
