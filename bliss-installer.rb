#!/usr/bin/env ruby
puts 'Installing Bliss Collector... please wait'
puts `git clone https://github.com/founderbliss/collector.git C:/tools/blisscollector`
puts 'Installing dependencies... please wait'
puts `@powershell Set-ExecutionPolicy RemoteSigned; powershell.exe C:/tools/blisscollector/installscripts/setup.ps1`
puts 'Installation complete.'