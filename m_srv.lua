print("starting hc server on port 87")
hc_server=net.createServer(net.TCP,10) 
local_cmd=function(file,input)
		pl=input
		inp=pl
		--print(pl)
		if     string.find(pl,'node_') then
                	dofile("m_srv_node.lc")
		elseif  string.find(pl,'GET /') and m.http then
                	dofile("m_srv_http.lc")			
		elseif (string.find(pl,'battery_') and m.battery) then
			dofile("m_srv_battery.lc")				
		elseif (string.find(pl,'onwake_') and m.onwake) then
			dofile("m_srv_onwake.lc")	
		elseif (string.find(pl,'dimmer_') and m.dimmer) then
			dofile("m_srv_dimmer.lc") 
		elseif (string.find(pl,'blind_[1-4]_') and m.blind) then
			dofile("m_srv_blind.lc")
		elseif (string.find(pl,'buzzer') and m.buzzer) then
			dofile("m_srv_buzzer.lc") 
		elseif (string.find(pl,'speaker') and m.speaker) then
			dofile("m_srv_speaker.lc") 
		elseif (string.find(pl,'pir_') and m.pir) then
			dofile("m_srv_pir.lc")
		elseif (string.find(pl,'car_') and m.car) then
			dofile("m_srv_car.lc")
		elseif (string.find(pl,'dist_') and m.hr04) then
			dofile("m_srv_hr04.lc")
		elseif (string.find(pl,'stepper_') and m.stepper) then
			dofile("m_srv_stepper.lc")
		elseif (string.find(pl,'log_') and m.log) then
			dofile("m_srv_log.lc")
		elseif (string.find(pl,'ds1820_') and m.ds1820) then
			dofile("m_srv_ds1820.lc")
		elseif (string.find(pl,'petdoor_') and m.petdoor) then
			dofile("m_srv_petdoor.lc")
		else 
			hc_server_responce=("No module "..pl.." found\nOptions are:\nnode_,dimr_,buzzer,speaker,button,petdoor.blind_[1-4]_,car_,dist_,log_\nif enabled in init_starup.lc")	
		end
end
hc_server:listen(80,function(con) 
	con:on("receive", function(con, conin) 
		if inp and string.find(inp,'GET /') then
			local resp=('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n<!DOCTYPE HTML><html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><meta http-equiv="refresh" content="'..m.http_refresh..'"><meta name="viewport" content="width=device-width, initial-scale=1"><title>'..m.http_title..'</title>')
			resp=resp..'<style type=text/css>'
			resp=resp..'* {margin: 0;padding: 0;}'
			resp=resp..'html,	body {height: 100%;font-family: sans-serif;text-align: center;background: #444d44;}'
			resp=resp..'#content {position: absolute;top: 0;right: 0;bottom: 0;left: 0;width: 320px;height: 480px;margin: auto;}'
			resp=resp..'input,button,select {-webkit-appearance: none;border-radius: 0;}'
			resp=resp..'input {border: 1px solid #ccc;	margin-bottom: 10px;width: 100%;box-sizing: border-box;color: #222;font: 16px monospace;padding: 15px;}'
			resp=resp..'button {color: #fff;border: 0;border-radius: 3px;cursor: pointer;display: block;font: 16px sans-serif;text-decoration: none;padding: 10px 5px;background: #31b457;width: 100%;}'
			resp=resp..'button:focus,button:hover {box-shadow: 0 0 0 2px #fff, 0 0 0 3px #31b457;}'
			resp=resp..'h3 {font-size: 16px;color: #666;margin-bottom: 20px;}'
			resp=resp..'h4 {color: #ccc;padding: 10px;}'
			resp=resp..'#i {text-align: center;}'
			resp=resp..'</style></head>'
			inp=nil
			con:send(resp..'\n')
			resp=nil
		end
		local_cmd(conin,conin)
		con:send(hc_server_responce.."\n")	
    end) 	
	
	con:on("sent", function(con) 
		if http_end then
			http_end=nil
	--		con:close()
	--		collectgarbage()
		end
		--hc_server_responce=nil
	end)
	
end)
--node.compile("m_srv.lua")