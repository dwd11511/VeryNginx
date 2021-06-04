-- -*- coding: utf-8 -*-
-- @Date    : 2016-01-02 00:46
-- @Author  : Alexa (AlexaZhou@163.com)
-- @Link    : 
-- @Disc    : filter request'uri maybe attack

local _M = {}

local VeryNginxConfig = require "VeryNginxConfig"
local request_tester = require "request_tester"
local http = require("http").new()

function _M.alert(url, mail, keyword)
    local res, err = http:request_uri(url.."?mail="..mail.."&alert="..keyword, {
	method = "GET"
    })
    if not res then
	ngx.log(ngx.ERR, "request failed: ", err)
    end
end

function _M.filter()
    
    if VeryNginxConfig.configs["filter_enable"] ~= true then
        return
    end
 
    local matcher_list = VeryNginxConfig.configs['matcher']
    local mail_addr = VeryNginxConfig.configs['mail']
    local response_list = VeryNginxConfig.configs['response']
    local response = nil

    for i,rule in ipairs( VeryNginxConfig.configs["filter_rule"] ) do
        local enable = rule['enable']
        local matcher = matcher_list[ rule['matcher'] ] 
        if enable == true and request_tester.test( matcher ) == true then
            local action = rule['action']
            if rule['alert'] ~= nil then
                ngx.log(ngx.ERR, "alert start")
                _M.alert("http://192.168.220.1:8000/send_mail", mail_addr, rule['alert'])
            else
		ngx.log(ngx.ERR, "alert empty")
	    end
            if action == 'accept' then
                return
            else
                if rule['response'] ~= nil then
                    ngx.status = tonumber( rule['code'] )
                    response = response_list[rule['response']]
                    if response ~= nil then
                        ngx.header.content_type = response['content_type']
                        ngx.say( response['body'] )
                        ngx.exit( ngx.HTTP_OK )
                    end
                else
                    ngx.exit( tonumber( rule['code'] ) )
                end
            end
        end
    end
end

return _M
