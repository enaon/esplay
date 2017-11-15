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
	tmr.register(rc522_tmr, 1000, tmr.ALARM_AUTO, function () 	
		isTagNear, cardType = RC522.request()
		if isTagNear == true then
			err, serialNo = RC522.anticoll()
			print("Tag Found: "..appendHex(serialNo).."  of type: "..appendHex(cardType))
			m.rc522tag=appendHex(serialNo)
			buf = {}
      		buf[1] = 0x50  --MF1_HALT
      		buf[2] = 0
		else
		print("Tag not Found")
			m.rc522tag="none"
		end
	end)
	tmr.start(rc522_tmr)
end
--node.compile("m_srv_rc522.lua")
--print(node.heap())