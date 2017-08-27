hc_server_responce=("No command "..pl.." found\nOptions are:\nstatus_get")	
if string.find(pl,'status_get$')  then
	_G["PIR_"..string.match(pl, "pir_([1-5])_lights").."_state"]="lights"
	hc_server_responce=_G["PIR_"..string.match(pl, "pir_([1-5])_lights").."_state"]

end


if  m.status=="enabled" then
	m.status="started"
	for var,val in pairs(_G) do
			if string.find(var,'PIR_[1-5]_status$') then

			elseif string.find(var,'dimmer_[1-5]_position$') then
			
			end
	end
end

--dofile("m_srv_status.lua")
--node.compile("m_srv_status.lua")
--print(node.heap())
