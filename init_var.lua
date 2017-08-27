--g--gpiomap 1-5,2-4,3-0,4-2,5-14,6-12,7-13,8-15,9=3,10-1,11-9,12-10
--set role
node_role="role=master\ntype=n7v1"
--enable modules
set_modules=function()	  
	m.wifi="enabled"
	--m.dimmer="enabled"
	m.blind="enabled"
	--m.button="enabled"
	--m.buzzer="enabled"
	--m.speaker="enabled"
	--m.pir="enabled"
	--m.oled="enabled"
	--m.lasertrap=enabled"
	--m.car="enabled"
	--m.hr04="enabled"
	--m.rc522="enabled"
	--m.log="enabled"
	if  m.wifi=="enabled" then
		node_name="generic"
		node_cssid="driot"
		node_cpass="k0d1k0s3"
		--node_cssid="D3-iot"
		--node_cpass="10t-play"
		node_assid="D3-iot"
		node_apass="10t-play"
		node_wifimode=1 --1=sta/2=ap/3=sta&ap
		node_cip="dhcp" --static/dhcp
		node_cipaddr="192.168.50.2"
		node_cipgw="192.168.50.1"
		node_aipaddr="192.168.50.1"
		node_aipgw="192.168.50.1"
		dofile("init_wifi.lc")  wifi_setup() wifi_setup=nil
		wifi.sleeptype(wifi.NONE_SLEEP) --wifi.NONE_SLEEP, wifi.LIGHT_SLEEP, wifi.MODEM_SLEEP
	end	 
end
init_modules=function()	 
if ( m.dimmer=="enabled") then
	LED1=3  --0
	LED2=4  --0
	--LED2=3  --5
	--LED3=3  --4
	--LED3=3  --0
	--LED4=4  --2
dofile("m_srv_dimmer.lc")
dofile("m_srv_dimmer_func.lc")
end
--m_button_start 
if ( m.button=="enabled") then
--mikro koumpi
	m.button_1=6 --gpio 
	m.button_1_press=0 
	m.button_1_PIR="PIR_1" 
--	button_1_group_sync_LED="LED1"
--	button_1_group_sync={}
-- button_1_group_sync["192.168.7.190-dimr_set_1_btn_sync_"] = "remote_cmd" 
	button_1_group_dn={}
 	button_1_group_dn["192.168.7.185-dimr_set_1_btn_dn"] = "remote_cmd"
	button_1_group_up={}
 	button_1_group_up["192.168.7.185-dimr_set_1_btn_up"] = "remote_cmd"
 	button_1_group_long_up={}
 	button_1_group_long_up["192.168.7.185-dimr_set_1_btn_up"] = "remote_cmd"
--megalo koumpi
	m.button_2=7 --gpio
	m.button_2_press=0 
	m.button_2_PIR="PIR_1" 
--	button_2_group_sync_LED={}
--	button_2_group_sync_LED["192.168.7.185-dimr_set_1_btn_sync_get"] = "remote_cmd"
	button_2_group_sync={}
	button_2_group_sync["192.168.7.185-dimr_set_1_btn_sync_"] = "remote_cmd" 
	button_2_group_dn={}
 	button_2_group_dn["192.168.7.185-dimr_set_1_btn_dn"] = "remote_cmd"
	button_2_group_up={}
 	button_2_group_up["192.168.7.185-dimr_set_1_btn_up"] = "remote_cmd"
 	button_2_group_long_up={}
 	button_2_group_long_up["192.168.7.185-dimr_set_1_btn_up"] = "remote_cmd"
dofile("m_srv_button.lc")
end
--m_blind_start
if ( m.blind=="enabled") then
	--blind_min,blind_max=30,125 -- servo limmits
	blind_min,blind_max,blind_speed,blind_speedUp,blind_freq=56,240,30,20,1000 -- servo limmits stronger
	blind1_pin=3		--gpio2, blind_pin var goes to server_blind
	blind1_state="closed"
	blind1_position=56
	--blind2_pin=5
	--blindpwr1_pin=3 --gpio0 , blindpwr_pin var goes to server_blind
	dofile("m_srv_blind.lc")
end
--m_buzzer start [ buzzer(050,10) ]
if (m.buzzer=="enabled") then
	buzzer_pin=5  
dofile("m_srv_buzzer.lc")
end
if (m.speaker=="enabled") then
	speaker_pin=3  
--dofile("m_srv_speaker.lc")
end
--m_pir_start
if ( m.pir=="enabled") then
	PIR_1=3
	PIR_1_state="lights" --lights|disabled|alarm
 	PIR_1_group_lights_on={}
--	PIR_1_group_lights_on["192.168.7.185-dimr_set_1_pir_use_1"] = "remote_cmd"
 	PIR_1_group_lights_on["192.168.7.185-dimr_set_1_pir_993"] = "remote_cmd"
	PIR_1_group_lights_off={}
	PIR_1_group_lights_off["192.168.7.185-dimr_set_1_pir_release"] = "remote_cmd"
	PIR_1_group_lights_off["192.168.7.195-dimr_set_2_pir_000"] = "remote_cmd"
-- 	PIR_1_group_lights_off["192.168.7.185-dimr_set_1_pir_000"] = "remote_cmd"
 	PIR_1_group_alarm_on={}
-- 	PIR_1_group_alarm_on["m_hc_server_buzzer.lc-buzzer_50_50_1"] = "local_cmd"
	PIR_1_group_alarm_off={}
-- 	PIR_1_group_alarm_off["m_hc_server_buzzer.lc-buzzer_50_50_3"] = "local_cmd"
dofile("m_srv_pir.lc")
end
if ( m.car=="enabled") then
	spdFactor=1
	car_pwm_1=1	--1,2EN     D1 GPIO5
	car_pwm_2=2	--3,4EN     D2 GPIO4
	car_dir_1=3		--1A  ~2A   D3 GPIO0
	car_dir_2=4		--3A  ~4A   D4 GPIO2
dofile("m_srv_car.lc")
end
if ( m.hr04=="enabled") then
	TRIG_PIN = 5
	ECHO_PIN = 6
	TRIG_INTERVAL = 15
	max_dist=30
	AVG_READINGS = 2
	CONTINUOUS = false
dofile("m_srv_hr04.lc")
end
if ( m.rc522=="enabled") then
	pin_rst = 3                 -- Enable/reset pin
	pin_ss = 4                  -- SS (marked as SDA) pin
dofile("m_srv_rc522_func.lc")	
dofile("m_srv_rc522.lc")
end
end
--print(node.heap())
--node.compile("init_var.lua")