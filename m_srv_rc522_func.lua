mode_idle,mode_auth,mode_receive,mode_transmit,mode_transrec,mode_reset,mode_crc = 0x00,0x0E,0x08,0x04,0x0C,0x0F,0x03
auth_a,auth_b = 0x60,0x61
act_read,act_write = 0x30,0xA0
act_increment,act_decrement = 0xC1,0xC0
act_restore,act_transfer,act_reqidl,act_reqall,act_anticl,act_select,act_end = 0xC2,0xB0,0x26,0x52,0x93,0x93,0x50
reg_tx_control = 0x14
length,num_write,authed = 16,0,false
keyA = { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF }      --  this is the usual default key (but may not always be)
RC522 = {}
RC522.__index = RC522
function appendHex(t)
  strT = ""
  for i,v in ipairs(t) do
    strT = strT.." 0x"..string.format("%X", t[i])
  end
  return strT
end
function RC522.dev_write(address, value)
    gpio.write(pin_ss, gpio.LOW)
    num_write = spi.send(1, bit.band(bit.lshift(address,1), 0x7E), value)
    gpio.write(pin_ss, gpio.HIGH)
end
function RC522.dev_read(address)
    local val = 0;
    gpio.write(pin_ss, gpio.LOW)
    spi.send(1,bit.bor(bit.band(bit.lshift(address,1), 0x7E), 0x80))
    val = spi.recv(1,1)
    gpio.write(pin_ss, gpio.HIGH)
    return string.byte(val)
end
function RC522.set_bitmask(address, mask)
    local current = RC522.dev_read(address)
    RC522.dev_write(address, bit.bor(current, mask))
end
function RC522.clear_bitmask(address, mask)
    local current = RC522.dev_read(address)
    RC522.dev_write(address, bit.band(current, bit.bnot(mask)))
end
function RC522.getFirmwareVersion()
  return RC522.dev_read(0x37)
end
function RC522.card_write(command, data)
    back_data = {}
    back_length = 0
    local err = false
    local irq = 0x00
    local irq_wait = 0x00
    local last_bits = 0
    n = 0
    if command == mode_auth then
        irq = 0x12
        irq_wait = 0x10
    end
    if command == mode_transrec then
        irq = 0x77
        irq_wait = 0x30
    end
    RC522.dev_write(0x02, bit.bor(irq, 0x80))       -- CommIEnReg
    RC522.clear_bitmask(0x04, 0x80)                 -- CommIrqReg
    RC522.set_bitmask(0x0A, 0x80)                   -- FIFOLevelReg
    RC522.dev_write(0x01, mode_idle)                -- CommandReg - no action, cancel the current action
    for i,v in ipairs(data) do
        RC522.dev_write(0x09, data[i])              -- FIFODataReg
    end
    RC522.dev_write(0x01, command)           -- execute the command
    if command == mode_transrec then
        RC522.set_bitmask(0x0D, 0x80)               -- BitFramingReg
    end
    i = 25  --- WAS 20000
    while true do
        tmr.delay(1)
        n = RC522.dev_read(0x04)                    -- ComIrqReg
        i = i - 1
        if  not ((i ~= 0) and (bit.band(n, 0x01) == 0) and (bit.band(n, irq_wait) == 0)) then
            break
        end
    end
    RC522.clear_bitmask(0x0D, 0x80)                 -- StartSend = 0
    if (i ~= 0) then                                -- Request did not timeout
        if bit.band(RC522.dev_read(0x06), 0x1B) == 0x00 then        -- Read the error register and see if there was an error
            err = false
			if (command == mode_transrec) then
                n = RC522.dev_read(0x0A)            -- find out how many bytes are stored in the FIFO buffer
                last_bits = bit.band(RC522.dev_read(0x0C),0x07)
                if last_bits ~= 0 then
                    back_length = (n - 1)* 8 + last_bits
                else
                    back_length = n *8
                end

                if (n == 0) then
                    n = 1
                end 
                if (n > length) then   -- n can't be longer that 16
                    n = length
                end
                for i=1, n do
                    xx = RC522.dev_read(0x09)
                    back_data[i] = xx
                end
              end
        else
            err = true
        end
    end
    return  err, back_data, back_length 
end
function RC522.request()
    req_mode = { 0x26 }   -- find tag in the antenna area (does not enter hibernation)
    err = true
    back_bits = 0
    RC522.dev_write(0x0D, 0x07)         -- bitFramingReg
    err, back_data, back_bits = RC522.card_write(mode_transrec, req_mode)
    if err or (back_bits ~= 0x10) then
        return false, nil
     end
    return true, back_data
end
function RC522.anticoll()
    back_data = {}
    serial_number = {}
    serial_number_check = 0
    RC522.dev_write(0x0D, 0x00)
    serial_number[1] = act_anticl
    serial_number[2] = 0x20
    err, back_data, back_bits = RC522.card_write(mode_transrec, serial_number)
    if not err then
        if table.maxn(back_data) == 5 then
            for i, v in ipairs(back_data) do
                serial_number_check = bit.bxor(serial_number_check, back_data[i])
            end 
            
            if serial_number_check ~= back_data[4] then
                err = true
            end
        else
            err = true
        end
    end
    return error, back_data
end
