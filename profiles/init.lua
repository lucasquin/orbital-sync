local lapis = require("lapis")
local http = require("lapis.nginx.http")
local json = require("cjson")
local app = lapis.Application()

local profiles = {
	{ user_id = 1, avatar = "alice.jpg", description = "Engenheira DevOps", joined_date = "2023-01-10" },
	{ user_id = 2, avatar = "bob.jpg", description = "Desenvolvedor Backend", joined_date = "2023-03-22" },
	{ user_id = 3, avatar = "carol.jpg", description = "Analista de Sistemas", joined_date = "2023-06-15" },
}

app:enable("etlua")
app.layout = false

app:before_filter(function(self)
	self.res.headers["Access-Control-Allow-Origin"] = "*"
	self.res.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
	self.res.headers["Access-Control-Allow-Headers"] = "Content-Type"

	if self.req.method == "OPTIONS" then
		return { status = 200 }
	end
end)

app:get("/", function()
	return {
		json = {
			name = "Profile API Service",
			version = "1.0.0",
			status = "online",
			endpoints = {
				"/profiles",
				"/profiles/:user_id",
				"/health",
				"/status",
			},
		},
	}
end)

app:get("/profiles", function()
	local status = Check_api1_status()

	return {
		json = {
			profiles = profiles,
			api1_status = status,
		},
	}
end)

app:get("/profiles/:user_id", function(self)
	local user_id = tonumber(self.params.user_id)
	for _, profile in ipairs(profiles) do
		if profile.user_id == user_id then
			return { json = profile }
		end
	end

	return { status = 404, json = { error = "Perfil não encontrado" } }
end)

app:get("/health", function()
	return {
		json = {
			status = "healthy",
			timestamp = os.time(),
			service = "profiles-api",
		},
	}
end)

app:get("/status", function()
	local api1_status = Check_api1_status()

	return {
		json = {
			api1 = api1_status,
			api2 = {
				status = "healthy",
				timestamp = os.time(),
			},
		},
	}
end)

function Check_api1_status()
	local status = {
		status = "unknown",
		timestamp = os.time(),
	}

	local ok, res = http.simple({
		url = "http://api1-service:8080/health",
		method = "GET",
		timeout = 1,
	})

	if ok and res.status == 200 then
		local body = json.decode(res.body)
		status = {
			status = body.status,
			timestamp = body.timestamp,
			service = body.service,
		}
	else
		status.status = "unavailable"
	end

	return status
end

app:match("/*", function()
	return { status = 404, json = { error = "Rota não encontrada" } }
end)

return app
