-- Copyleft 2011 -- pancake nopcode.org --

local http = require ("http")

local function table_keys(a)
	b={}
	if type (a) == 'string' then
		b[#b+1] = a
	else
		for k,v in pairs (a) do
			b[#b+1] = k
		end
	end
	return b
end

local Request = function()
	local this = {}
	this.method = process.env['REQUEST_METHOD'];
	this.headers = {}
	this.headers['host'] = process.env['HTTP_HOST']
	this.headers['user-agent'] = process.env['HTTP_USER_AGENT']
	this.url = process.env['REQUEST_URI'];
	return this
end

local Response = function()
	local this = {}
	local body = false;

	this.write_head = function(self, a0, a1, a2)
		local reason = a2 or "unknown"
		local headers = a1
		local status = a0
		local arguments = { a0, a1, a2}

		if not (type (reason) == 'string') then
			headers = reason
			reason = "OK"
		else
			if http.STATUS_CODES[a0] then
				reason = http.STATUS_CODES[a0] or 'unknown';
			else
				reason = "OK" -- XXX
			end
		end

		print ('Status: '..status..' '..reason)

		local field
		local value
		local keys = table_keys (headers)
		local isArray = (type (headers) == "table")
		for i = 1, #keys do
			local key = keys[i]
			if isArray then
				-- XXX isArray is not supported
				field = key
				value = headers[key]
			else
				field = key;
				value = headers[key]
			end
			if not value then value = "" end
			print (field..": "..value);
		end
	end

	this.write = function(self, message)
		if not body then
			body = true;
			print ("");
		end

		if message then
			print (message)
		end
	end

	this.flush = function()
		-- do nothing
	end

	this.finish = function(self, body)
		self:write (body)
		-- XXX: second arg must be a table
		-- self.write.apply (this, {a0,a1,a2});
	end
	return this
end

local Server = function(listener, options)
	local s = {}
	local request = Request ()
	local response = Response ()

	s.listen = function()
		listener (request, response)
	end
	return s
end

local CGI = {}
function CGI.create_server (listener, options)
    return Server (listener, options)
end
return CGI
