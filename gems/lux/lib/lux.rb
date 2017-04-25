require_relative './lux/lock'

module Lux
  LOCK_OK = 200
  LOCK_RENEWED = 205
  LOCK_NOT_FOUND = 404
  LOCK_NOT_OWNED = 401
end