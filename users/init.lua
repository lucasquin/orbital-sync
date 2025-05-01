local lapis = require("lapis")
local http = require("lapis.nginx.http")
local json = require("cjson")
local app = lapis.Application()

local users = {
	{ id = 1, name = "Alice", role = "admin" },
	{ id = 2, name = "Bob", role = "user" },
	{ id = 3, name = "Carol", role = "user" },
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
			name = "User API Service",
			version = "1.0.0",
			status = "online",
			endpoints = {
				"/users",
				"/users/:id",
				"/health",
			},
		},
	}
end)

app:get("/users", function()
	return { json = users }
end)

app:get("/users/:id", function(self)
	local id = tonumber(self.params.id)
	for _, user in ipairs(users) do
		if user.id == id then
			local ok, res = http.simple({
				url = "http://api2-service:8081/profiles/" .. id,
				method = "GET",
			})

			if ok and res.status == 200 then
				local profile = json.decode(res.body)
				local result = {
					id = user.id,
					name = user.name,
					role = user.role,
					profile = profile,
				}
				return { json = result }
			else
				return { json = user }
			end
		end
	end

	return { status = 404, json = { error = "Usuário não encontrado" } }
end)

app:get("/health", function()
	return {
		json = {
			status = "healthy",
			timestamp = os.time(),
			service = "users-api",
		},
	}
end)

app:match("/*", function()
	return { status = 404, json = { error = "Rota não encontrada" } }
end)

return app
