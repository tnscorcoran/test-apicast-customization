local get_token = require 'oauth.apicast_oauth.get_token'
local callback = require 'oauth.apicast_oauth.authorized_callback'
local authorize = require 'oauth.apicast_oauth.authorize'
local setmetatable = setmetatable

local http_ng = require "resty.http_ng"
local env = require 'resty.env'
local cjson = require 'cjson'

local _M = {
  _VERSION = '0.1'
}

local mt = { __index = _M }

function _M.new(service)
  return setmetatable(
    {
      authorize = authorize.call,
      callback = callback.call,
      get_token = get_token.call,
      service = service
    }, mt)
end

function _M:transform_credentials(credentials)

  local url = 'http://tc-idp.herokuapp.com/mock-auth-service'

  local http_client = http_ng.new{
    options = {
      ssl = { verify = env.enabled('OPENSSL_VERIFY') }
    }
  }

  local res = http_client.post(url, { access_token = credentials.access_token} )
  
  if res.status == 200 and res.body then
    body = cjson.decode(res.body)
    authorized = body.authorized
    if authorized then
      local app_id = body.aud
      local ttl = body.exp
      -- oauth credentials for keycloak
      -- @field app_id Client id
      -- @table credentials_oauth
      return { app_id = app_id }, ttl
    end
  end
  return nil, nil, 'not authorized'
end

return _M
