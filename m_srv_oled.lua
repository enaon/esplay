hc_server_responce=("No command "..pl.." found\n-options are oled_[time_|date_|line1_|line2_]")
print(pl)
if  pl=='oled_refresh' then
	oled_refresh()
	hc_server_responce=("oled_refresh")
elseif  pl=='oled_clear' then
	 oled_clear()
	hc_server_responce=("oled_cleared")
elseif  pl=='oled_refresh_cont' then
	 oled_refresh_tmr:start()
	hc_server_responce=("oled_refresh_cont")
elseif  pl=='oled_refresh_stop' then
	 oled_refresh_tmr:stop()
	hc_server_responce=("oled_refresh_stoped")

end


if  m.oled=="enabled" then
	m.oled="started"
    i2c.setup(0, m.oled_sda_pin, m.oled_scl_pin, i2c.SLOW)
    disp = u8g.ssd1306_128x64_i2c(0x3c) --init oled i2c display
    
    oled_refresh_tmr=tmr.create()
    oled_refresh_tmr:register(m.oled_refresh, tmr.ALARM_AUTO, function (t) 
        oled_refresh()
    end)

    function oled_clear()
          m.oled_temp,m.oled_time,m.oled_line1gr,m.oled_line2gr,m.oled_line1en,m.oled_line2en,m.oled_largegr,m.oled_largeen,m.oled_info,m.oled_page="","","","","","","","","",""   
    end

    function oled_refresh(void)
        disp:firstPage() 
        repeat
        disp:setFontRefHeightExtendedText()
        disp:setDefaultForegroundColor()
        disp:setFontPosTop()
        disp:setFont(u8g.font_symb24r)
        disp:drawStr(0,35,m.oled_largegr)
        disp:setFont(u8g.font_ncenB24r)
        disp:drawStr(0,35,m.oled_largeen)
        disp:setFont(u8g.font_symb14r)
        disp:drawStr(0,25,m.oled_line1gr)
        disp:drawStr(0,60,m.oled_line2gr)
        disp:setFont(u8g.font_ncenB14r)
        disp:drawStr(0,25,m.oled_line1en)
        disp:drawStr(0,60,m.oled_line2en)
        disp:setFont(u8g.font_babyr)
        disp:drawStr(0,8,m.oled_info)
        disp:setFont(u8g.font_m2icon_9)
        disp:drawStr(disp:getWidth()-35,8,m.oled_page)
        --disp:setFont(u8g.font_unifont_77)
        disp:drawStr(0,15,m.oled_page)
        disp:setFont(u8g.font_freedoomr25n)
        disp:drawStr(60,52,m.oled_temp)
        disp:drawStr(40,52,m.oled_time)
        until disp:nextPage() == false 
    end
oled_refresh()
end

--dofile("m_srv_oled.lua")
--node.compile("m_srv_oled.lua")
--print(node.heap())