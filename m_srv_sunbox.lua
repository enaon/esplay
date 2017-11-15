hc_server_responce=("No command "..pl.." found\n-options are sunbox_door_[lock|unlock|toggle|state],sunbox_side_[open|close|toggle]")
--requires oled-buzzer modules loaded
--m_srv_commands
if  string.find(pl,'sunbox_door_')  then
    sunbox_oled_info_tmr:stop()
    sunbox_oled_info_tmr:start()
	local action=string.sub(pl, 13,19)   
	sunbox_door(action)
elseif string.find(pl,'sunbox_mode_state_') then --lock controll
    if pl=="sunbox_mode_state_booked" or pl=="sunbox_mode_state_vacant" or pl=="sunbox_mode_state_offline" then
        local action=string.sub(pl, 19,30)
        if action=="vacant" then m.sunbox_mode_state="Vacant" 
        elseif action=="offline" then m.sunbox_mode_state="Offline" 
        elseif action=="booked" then m.sunbox_mode_state="Booked" 
        --elseif action=="upkeep" then m.sunbox_mode_state="Upkeep" 
        end
    end
    hc_server_responce=("sunbox_mode_state="..m.sunbox_mode_state)
elseif string.find(pl,'sunbox_key_') then --key access controll
    sunbox_oled_info_tmr:stop()
    sunbox_oled_info_tmr:start()
    local action=string.sub(pl, 12,50)
    local message1=""
    local message2=""
    if action=="nokey" then 
        m.sunbox_key_present="no" m.sunbox_key_message=""
         if gpio.read(m.sunbox_door_pos_rid)==0 and m.sunbox_mode_state=="Booked" then
            message1="Wait"
            message2="Locking"
            sunbox_door("lock")
        else
            message1="OK"
            message2="Key ejected"
            buzzer(100,50,0)
        end
        if gpio.read(m.sunbox_door_pos_rid)==0 and m.sunbox_mode_state=="Booked" then
            message1="Wait"
            message2="Locking"
            sunbox_door("lock")
        end
        --buzzer(100,5,0)
    elseif action=="invalid" then 
        m.sunbox_key_present="no" m.sunbox_key_message=""
        message1="Invalid"
        message2="Wrong type"
        buzzer(100,50,0)
    elseif m.sunbox_mode_state=="Booked" then
        if action==m.sunbox_key_number then 
            m.sunbox_key_present="yes" 
            m.sunbox_key_message="Valid Key " 
            if  m.sunbox_door_state=="locked" then 
                message1="Hello"
                message2="Unlocked"
                sunbox_door("unlock")
            else
                message1="Valid"
                message2="I am yours"
                buzzer(400,100,0)
            end
        elseif action~=m.sunbox_key_number then 
            m.sunbox_key_present="invalid" 
            m.sunbox_key_message="Invalid Key"
            message1="Invalid"
            message2="Wrong Key"
            buzzer(100,50,0)
        end
    elseif m.sunbox_mode_state=="Vacant" then
        m.sunbox_key_number=action
        m.sunbox_key_present="yes"
        m.sunbox_mode_state="Booked"
        m.sunbox_key_message="Valid Key"
        message1="Hello"
        message2="I am yours"
        if m.sunbox_door_state=="locked" then
            sunbox_door("unlock")
        else  buzzer(100,50,2)
        end
    elseif m.sunbox_mode_state=="Offline" then
        m.sunbox_key_message="not accepted"
        m.sunbox_key_present="yes"
        message1="Invalid"
        message2="out of order"
        buzzer(100,200,1)
    end
    hc_server_responce=("sunbox_key_present_"..m.sunbox_key_present.."\nsunbox_key_number_"..m.sunbox_key_number)
    m.oled_largeen=message1  m.oled_line2en=message2
    oled_refresh()
    --
end

--dofile("m_srv_sunbox.lua")
--node.compile("m_srv_sunbox.lua")
--print(node.heap())