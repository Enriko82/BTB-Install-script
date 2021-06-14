#!/bin/bash  
########################################################################################################################################################  
# Run the following commands in the SSH client  
# Do this in the same terminal screen folder, as the bot was installed  
# 		vi remove.sh  
# Copy everything from this file into the VI screen.   
# Press Esc button and Shift + ZZ  
# 		sudo chmod +x remove.sh  
# 		./remove.sh  
# Fill in below the folder where the Binance trade bot was installed  
BinanceFolder=Binance1
  
sudo systemctl stop BTB${BinanceFolder}.service  
sudo systemctl disable BTB${BinanceFolder}.service  
sudo rm -f /etc/systemd/system/BTB${BinanceFolder}.service   

sudo systemctl stop BTBTelegram${BinanceFolder}.service  
sudo systemctl disable BTBTelegram${BinanceFolder}.service  
sudo rm -f /etc/systemd/system/BTBTelegram${BinanceFolder}.service  
  
rm -rf ${BinanceFolder}  
