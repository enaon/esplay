hc_server_responce=("No command "..pl.." found\nOptions are:\nrc522_[]")	
if string.sub(pl, 1, 6)=="rc522_"  then
hc_server_responce=("responce:")		
end

-- start
if m.rc522=="enabled" then
	m.rc522="started"
	spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
	gpio.mode(pin_rst,gpio.OUTPUT)
	gpio.mode(pin_ss,gpio.OUTPUT)
	gpio.write(pin_rst, gpio.HIGH)
	gpio.write(pin_ss, gpio.HIGH) 
	RC522.dev_write(0x01, mode_reset)
	RC522.dev_write(0x2A, 0x8D)
	RC522.dev_write(0x2B, 0x3E)   
	RC522.dev_write(0x2D, 30)      
	RC522.dev_write(0x2C, 0)         
	RC522.dev_write(0x15, 0x40)    
	RC522.dev_write(0x11, 0x3D)  
	current = RC522.dev_read(reg_tx_control)
	if bit.bnot(bit.band(current, 0x03)) then
		RC522.set_bitmask(reg_tx_control, 0x03)
	end
	rc522_tmr=tmr.create()
	print("Rfid Starting\nRC522 Firmware Version: 0x"..string.format("%X", RC522.getFirmwareVersion()))
	local tag_loop=0
	tmr.register(rc522_tmr, 1000, tmr.ALARM_AUTO, function () 
		print(tag_loop, m.rc522_tag)
		tag_loop=tag_loop+1	
		isTagNear, cardType = RC522.request()
		if isTagNear == true then
			err, serialNo = RC522.anticoll()
			print("Tag Found: "..appendHex(serialNo).."  of type: "..appendHex(cardType))
			local tag=appendHex(serialNo)
			if m.rc522_tag~=tag then 
				m.rc522_tag=tag
				
				remote_cmd(m.rc522_lock,"sunbox_key_"..m.rc522_tag)
				rc522_tmr1=tmr.create()
				tmr.register(rc522_tmr1, 1000, tmr.ALARM_SINGLE, function () 
					tmr.start(rc522_tmr)
					tmr.unregister(rc522_tmr1)
				end)
				tmr.start(rc522_tmr1)
				tmr.stop(rc522_tmr)
				
			end
			buf = {}
      		buf[1] = 0x50  --MF1_HALT
      		buf[2] = 0
			tag_loop=0
		else
			print("Tag not Found")
			if tag_loop>=2 and m.rc522_tag~="nokey" then
				m.rc522_tag="nokey"
				remote_cmd(m.rc522_lock,"sunbox_key_nokey")
				rc522_tmr1=tmr.create()
				tmr.register(rc522_tmr1, 1000, tmr.ALARM_SINGLE, function () 
					tmr.start(rc522_tmr)
					tmr.unregister(rc522_tmr1)
				end)
				tmr.start(rc522_tmr1)
				tmr.stop(rc522_tmr)
			end
		end
	end)

	rc522_send_tmr=tmr.create()
	tmr.register(rc522_send_tmr, 20, tmr.ALARM_AUTO, function () 
		remote_cmd(m.rc522_lock,"sunbox_key_"..m.rc522_tag)
		tmr.stop(rc522_send_tmr)
	end)


	if m.rc522_button_id then 
		m.rc522_get_keyno_last=0
		function rc522_get_keyno()
--			print("Tag get")
    		--bounce filter
        	local delay = 100000 
			local now = tmr.now()
			local delta = now - m.rc522_get_keyno_last
			if delta < 0 then delta = delta + 2147483647 end
			if delta < delay then  return end
			

			--
			if gpio.read(m.rc522_button_id)==0 then
				tmr.stop(rc522_send_tmr)
				gpio.trig(m.rc522_button_id, 'up', rc522_get_keyno)
				m.rc522_get_keyno_last=tmr.now()
				isTagNear, cardType = RC522.request()
				if isTagNear ~= true then
					isTagNear, cardType = RC522.request()
				end
				if isTagNear == true then
					err, serialNo = RC522.anticoll()
					local tag=appendHex(serialNo)
--					print("tag:"..tag)
					m.rc522_tag=tag
--					print("Tag Found: "..appendHex(serialNo).."  of type: "..appendHex(cardType))
					buf = {}
      				buf[1] = 0x50  --MF1_HALT
      				buf[2] = 0
					tmr.start(rc522_send_tmr)
				else
					m.rc522_tag="invalid"
					tmr.start(rc522_send_tmr)
				end
			elseif gpio.read(m.rc522_button_id)==1 then
					tmr.stop(rc522_send_tmr)
					gpio.trig(m.rc522_button_id, 'down', rc522_get_keyno)
					m.rc522_tag="nokey"
					tmr.start(rc522_send_tmr)
					m.rc522_get_keyno_last=tmr.now()
				
			end
		end
	gpio.mode(m.rc522_button_id, gpio.INT, gpio.PULLUP)
	gpio.trig(m.rc522_button_id, 'down', rc522_get_keyno)
	
	else
		tmr.start(rc522_tmr)
	end

end
--node.compile("m_srv_rc522.lua")
--print(node.heap())