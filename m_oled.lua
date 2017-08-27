function refresh_oled(void)
i2c.setup(0, 5, 6, i2c.SLOW)
--function refresh_oled(void)
   disp:firstPage() 
   repeat
    disp:setFont(u8g.font_symb14r)
    disp:setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
    disp:drawStr(0,20,ol_body_large)
    disp:setFont(u8g.font_symb10r)
    disp:drawStr(0,35,ol_body_small_1)
    disp:drawStr(0,49,ol_body_small_2)
    disp:setFont(u8g.font_babyr)
    disp:drawStr(0,8,ol_info)
    disp:setFont(u8g.font_m2icon_9)
    disp:drawStr(disp:getWidth()-35,8,ol_page)
    disp:setFont(u8g.font_freedoomr25n)
    disp:drawStr(60,52,ol_temp)
    disp:drawStr(40,52,ol_time)
   until disp:nextPage() == false 

end

--dofile("m_refresh_oled.lua")
--node.compile("m_refresh_oled.lua")
--print(node.heap())