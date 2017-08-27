hc_server_responce=("No command "..pl.." found\n-options are hoop__[open|close|toggle],petdoor_side_[open|close|toggle]")

if  string.find(pl,'petdoor_side_')  then
	action=string.sub(pl, 14,19)   
	side_door(action)
	hc_server_responce=("petdoor_side_door="..m.petdoor_side_door_state)
elseif string.find(pl,'petdoor_front_')  then
	action=string.sub(pl, 15,20)
	front_door(action)
	hc_server_responce=("petdoor_front_door="..m.petdoor_front_door_state)
elseif string.find(pl,'petdoor_button_')  then
	action=string.sub(pl, 16,22)
	button(action)
	hc_server_responce=("petdoor_button="..m.petdoor_button_state)
	
end

servo=6 --servo-gpio 12
hoop=7 --ir module-gpio 13
fota=1 -- ws2812 rgb-gpio 5
led=5 -- led kolonas-gpio 14
speaker=2 --speaker-gpio 4
hooponce=0
initled=1


if  m.petdoor=="enabled" then
	m.petdoor="started"
	--

end
	
gpio.mode(speaker, gpio.OUTPUT) -- make a cheering sound
gpio.write(speaker, gpio.HIGH)
gpio.mode(led, gpio.OUTPUT) -- turn on green led 
gpio.write(led, gpio.HIGH)


--start modules 
tmr.alarm(1,100,1,function() --flash ws2812
  if(initled == 1)then
   ws2812.writergb(fota,string.char(255,255,255):rep(8))
   initled=2
  elseif(initled == 2) then
    initled=3
    ws2812.writergb(fota,string.char(255,0,0):rep(8))
  elseif(initled == 3) then
    initled=4
    ws2812.writergb(fota,string.char(255,0,255):rep(8))
  elseif(initled == 4) then
    initled=5
    ws2812.writergb(fota,string.char(0,255,0):rep(8))
  elseif(initled == 5) then
    initled=1
    ws2812.writergb(fota,string.char(0,0,255):rep(8))
  end 
end)
 
--move servo to end and back 
position=240 --all right
pwm.setup(servo, 100, position)
pwm.start(servo)
tmr.delay(1300000)
position=70 --all left
pwm.setup(servo, 100, position)
pwm.start(servo)
tmr.delay(2000000)
--tmr.stop(1)

-- gametime keeping using servo
position=70 --all left
tmr.alarm(2,300,1,function() 
	pwm.setup(servo, 100, position)
	pwm.start(servo)
	position=position+1
	if (position==241) then --all right
	  tmr.alarm(2,300,0,function()  
	    position=70 
	    pwm.setup(servo, 100, position)
	    pwm.start(servo)
	    tmr.delay(1500000)
	    pwm.stop(servo) 
	  end)
	end
end)

-- ball in hoop detection

gpio.mode(hoop,gpio.INPUT,gpio.FLOAT)
tmr.alarm(3,50,1,function()    
   if (gpio.read(hoop) == hooponce) then
	hooponce=2
	if (position > 90) then --give more time if ball in hoop
	  position = position - 20
	else 
	  position=70
	end
	gpio.mode(speaker, gpio.OUTPUT)
	gpio.write(speaker, gpio.HIGH)

	ws2812.writergb(fota,string.char(0,0,0,0,0,0))
  
	tmr.alarm(5,1000,0,function() 
	  hooponce=0
	ws2812.writergb(fota,string.char(255,0,0,255,255,50,0,205,0,0,255,0,0,0,255,102,178,255,0,155,255,255,0,0))
	end)
   end
end)


--loop recovery
tmr.alarm(6,2000,0,function()
	file.open("boot_status.lua", "w")
	file.write(1)
	file.close()
end)
