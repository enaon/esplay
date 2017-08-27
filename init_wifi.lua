function wifi_init()
	node_name="new"
	node_cssid="driot"
	node_assid="D3-iot"
	node_cpass="k0d1k0s3"
	node_apass="10t-play"
	node_wifimode=3 --1=sta/2=ap/3=sta&ap
	node_cip="dhcp" --static/dhcp
	node_cipaddr="192.168.50.3"
	node_cipgw="192.168.50.1"
	node_aipaddr="192.168.50.1"
	node_aipgw="192.168.50.1"
end

function wifi_setup()
if (boot_status~=true)then
-- recovery mode
-- Client Settings
	wifi.setmode(wifi.STATIONAP)
	wifi.sta.config(node_cssid,node_cpass)
	wifi.sta.sethostname(node_name.."-recovery")
	wifi.sta.autoconnect(1)
	wifi.sta.connect()
	if (node_cip=="static") then
		STA_IP_cfg =
		{
 		ip = node_cipaddr,
		netmask = "255.255.255.0",
		gateway = node_cipgw
		}
		wifi.sta.setip(STA_IP_cfg)
	end
-- AP settings
	AP_cfg={}
	AP_cfg.ssid=(node_name.."-recovery")
	AP_cfg.pwd=node_apass
	AP_cfg.auth=3
	wifi.ap.config(AP_cfg)
-- IP Address	
	AP_IP_cfg =
	{
	    ip="192.168.168.168",
	    netmask="255.255.255.0",
	    gateway="192.168.168.168"
	}
	wifi.ap.setip(AP_IP_cfg)
-- Dhcp Server
	dhcp_config ={}
	dhcp_config.start = "192.168.168.1"
	wifi.ap.dhcp.config(dhcp_config)
	wifi.ap.dhcp.start()
        print("leaving wifi config- failsafe recovery, upload service on port 87")
else
-- normal mode
-- client Settings
	wifi.setmode(node_wifimode)
	wifi.sta.config(node_cssid,node_cpass)
	wifi.sta.sethostname(node_name)
	wifi.sta.autoconnect(1)
	wifi.sta.connect()
	if (node_cip=="static") then
		STA_IP_cfg =
		{
 		ip = node_cipaddr,
		netmask = "255.255.255.0",
		gateway = node_cipgw
		}
		wifi.sta.setip(STA_IP_cfg)
	end
 	if (node_wifimode==3) then
-- AP settings
		AP_cfg={}
		AP_cfg.ssid=(node_assid)
		AP_cfg.pwd=node_apass
		AP_cfg.auth=3
		wifi.ap.config(AP_cfg)
-- IP Address	
		AP_IP_cfg =
		{
	    	ip=node_aipaddr,
	    	netmask="255.255.255.0",
	   	 gateway=node_aipgw
		}
		wifi.ap.setip(AP_IP_cfg)
-- Dhcp Server
		dhcp_config ={}
		dhcp_config.start = "192.168.50.10"
		wifi.ap.dhcp.config(dhcp_config)
		wifi.ap.dhcp.start()
	end
        print("leaving wifi config-normal booting")
end
end
--node.compile("init_wifi.lua")
