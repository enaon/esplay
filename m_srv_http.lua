hc_server_responce=("No command "..pl.." no http request found")


if string.find(pl,'GET /')  then
	--print("pl="..pl)
--	local resp=('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n<!DOCTYPE HTML><html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><meta http-equiv="refresh" content="'..m.http_refresh..'"><meta name="viewport" content="width=device-width, initial-scale=1"><title>'..m.http_title..'</title></head><body>')
	local resp='<body>'
--
	resp=resp..'<h5>heap:'..node.heap()..'</h5>'
--
	local _,_,vars = string.find(pl, "GET /%?(.+) HTTP")
	if (vars ~= nil) then
		local unescape = function (s)
			s = string.gsub(s, "+", " ")
			s = string.gsub(s, "%%(%x%x)", function (h)
				return string.char(tonumber(h, 16))
			end)
			return s
		end
		
		--print("vars="..vars)
		local _GET = {}
		for k, v in string.gmatch(vars, "(%w+)=([^%&]+)&*") do
			print (k, v)
			_GET[k] = unescape(v)
		end
		unescape,s=nil,ni
	end
--
	local getmodule=function(name)
		for var,val in pairs(m) do
			if string.find(var, name) and (string.find(var,'state') or string.find(var,'node_')) then
				local _,_,mvar=string.find(var, ""..name.."_(.*)")
				resp=resp..mvar..'='..val..'<br>'
				--print(var,val)
			end
		end
	end
	resp=resp..'<h3>modules</h3>'
	for var,val in pairs(m) do
		if val=="started" then
			resp=resp..'<h4>'..var
			resp=resp..'<h5>'
			getmodule(var)
			resp=resp..'</h5></h4>'
		end
	end
	

	
	
--
	--resp=resp..'<h2><input style="text-align: center" type="text" size=4 name="refresh" value="'..m.http_refresh..'"><br><br></h2>'
	--resp=resp..'<button onclick="location.href=\'http://'..wifi.sta.getip()..'/?refresh=1\'" type="button">refresh1</button>&nbsp;&nbsp;&nbsp;'
	resp=resp..'<button onclick="location.href=\'http://'..wifi.sta.getip()..'/?refresh=5\'" type="button">refresh5</button>&nbsp;&nbsp;&nbsp;'
	resp=resp..'<input type="submit" name="pwmi" value="10">\n'
	resp=resp..'</body></html>'
	hc_server_responce=resp
	resp=nil
	unescape=nil
	http_end=1
	--hc_server_responce="<html><head><title>ESP8266 LED Remote Control</title></head><body style='background-color:#FFFF77'><h1 style='color:blue'> ESP8266 Web Server</h1></body></html>"
	--hc_server_responce="</body></html>"
	
end

--if  m.http=="enabled" then
--m.http="started"
--end

--dofile("m_srv_http.lua")
--node.compile("m_srv_http.lua")
--print(node.heap())
