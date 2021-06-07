**BTB-Install-script**  
Binance trade bot and telegram bot installer  

This is an installation script for installing Binance Trade Bot on Oracle Free tier cloud, or Raspberry Pi or other Linux variants  

Copyright 2021 Enriko82  

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.  

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.  

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.  



Instructions how to install:  
Create a new instance in Oracle cloud, Raspberry/Debian like, or other type  
Make sure you can SSH into the server  
Set here in which folder you would like the Bot to be installed:  
By default the bot will be installed in the subfolder Binance1  
BinanceFolder=Binance1  
Update in the end of this file below the following chapters, by completing the data needed  
1) Fill in below your user.cfg details.  
2) Fill in below your supported coins, which you would like to trade  
3) Fill in below your Telegram Bot ID's  
Run the following commands in the SSH client  
		vi start.sh  
Copy everything from this file into the VI screen.   
Press Esc button and Shift + ZZ  
		sudo chmod +x start.sh  
		./start.sh  
if you want to install more bots, then update the Binancefolder variable, user.cfg, Supported coin list and apprise.yml section  
and update start.sh to eg start2.sh  
The script should run now and will ask you 2 questions  
1) Which Bot or Fork you would like to install  
2) On which system you will install it  
  
If you like this automated install script. Please go to:  
https://www.buymeacoffee.com/Enriko82  



More information about the Binance Trade Bot can be found here  
https://github.com/edeng23/binance-trade-bot  
If you like the Binance trade Bot. Please go to here to support:  
https://www.buymeacoffee.com/edeng   

More information about the Binance Trade Bot Manager Telegram can be found here  
https://github.com/lorcalhost/BTB-manager-telegram  
If you like the Binance Trade Bot Manager Telegram. Please go to here to support:  
https://www.buymeacoffee.com/lorcalhost  

End instructions  

