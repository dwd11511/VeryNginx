local util = require "util"
local VeryNginxConfig = require "VeryNginxConfig"
local scheme_lock = require "scheme_lock"
local redirect = require "redirect"
local uri_rewrite = require "uri_rewrite"
local filter = require "filter"

if ngx.var.vn_exec_flag and ngx.var.vn_exec_flag ~= '' then
    util.ngx_ctx_load()
    return
end

--At first , make sure every request use latest running config
VeryNginxConfig.update_config()

filter.filter()
scheme_lock.run()
uri_rewrite.run()
redirect.run()
