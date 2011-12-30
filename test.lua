local mode = "cgi"
local port = 5001

local req_handler = function (req, res)
	local body = "hello world"
	local headers = {}
	headers['Content-Type'] = 'text/plain'
	headers['Content-Length'] = #body
	res:write_head (200, headers)
	res:finish (body)
end

-- api not yet compatible
-- http://brianmckenna.org/blog/nodejs_via_cgi
--local CGI = require ("http")
local start = {}
start["cgi"] = function (x)
	local CGI = require ("cgi")
	local server = CGI.create_server (req_handler)
	server.listen ()
end
start["http"] = function (x)
	local HTTP = require ("http")
	local server = HTTP.create_server ("0.0.0.0", x, req_handler)
p ("Listening at port "..port)
end

start[mode](port)
