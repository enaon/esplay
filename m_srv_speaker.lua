hc_server_responce=("No command "..pl.." found\nOptions are:\nspeaker_[filename_[repetitions]")	
if string.sub(pl, 1, 8)=="speaker_"  then
	speak_file=string.sub(pl, 9)		
end
-- setup
if m.speaker=="enabled" then
   	m.speaker="started"
	hc_server_responce=("playing")		
	function cb_drained(d)
		print("drained "..node.heap())
		file.close()
		d:close()	
		gpio.mode(speaker_pin, gpio.OUTPUT)
		m.speaker="enabled"
	--file.seek("set", 0)
	-- uncomment the following line for continuous playback
	--d:play(pcm.RATE_8K)
	end
	function cb_stopped(d)
		print("playback stopped")
		file.close()
	end
	function cb_paused(d)
		print("playback paused")
	end
	if file.exists(speak_file) then file.open(speak_file, "r")
	else hc_server_responce=("no such file") m.speaker="enabled" return
	end
	drv = pcm.new(pcm.SD, speaker_pin)
	-- fetch data in chunks of FILE_READ_CHUNK (1024) from file
	drv:on("data", function(drv) return file.read() end)
	-- get called back when all samples were read from the file
	drv:on("drained", cb_drained)
	drv:on("stopped", cb_stopped)
	drv:on("paused", cb_paused)
	-- start playback
	drv:play(pcm.RATE_8K)
else
	hc_server_responce=("busy, please wait")		
end
--dofile("m_srv_speaker.lua")
--node.compile("m_srv_speaker.lua")
--print(node.heap())