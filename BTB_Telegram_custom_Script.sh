#!/bin/bash
# This is an installation script for installing Binance Trade Bot on Oracle Free tier cloud, or Raspberry Pi or other Linux variants
#
# Copyright 2021 Enriko82
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#
# Instructions how to install:
# Create a new instance in Oracle cloud or Raspberry
# Make sure you can SSH into the server
# Set here in which folder you installed the Bot:
# By default the bot will be installed in the subfolder Binance1
BinanceFolder=Binance1
# Run the following commands in the SSH client in the same folder as the start.sh script used here:
# 		vi scripts.sh
# Copy everything from this file into the VI screen. 
# Press Esc button and Shift + ZZ
# 		sudo chmod +x script.sh
# 		./script.sh
# if you want to deploy to more bots, then update the Binancefolder variable
# and update script.sh to eg script2.sh
# The script should run now and install the custom scripts
#
# If you like this automated install script. Please go to:
# https://www.buymeacoffee.com/Enriko82
#
#
## Version updates
# 1.0 09-06-2021
#
#
# More information about the Binance Trade Bot can be found here
# https://github.com/edeng23/binance-trade-bot
# If you like the Binance trade Bot. Please go to here to support:
# https://www.buymeacoffee.com/edeng 
#
# More information about the Binance Trade Bot Manager Telegram can be found here
# https://github.com/lorcalhost/BTB-manager-telegram
# If you like the Binance Trade Bot Manager Telegram. Please go to here to support:
# https://www.buymeacoffee.com/lorcalhost
#
# End instructions
########################################################################################################################################################

########################################################################################################################################################
# Retrieve current directory
# If $1 is not passed, set to the current working dir using $PWD
# Set current directory as install directory
_dir="${1:-${PWD}}"
 
## Die if $dir does not exists
[ ! -d "$_dir" ] && { echo "Error: Directory $_dir not found."; exit 2; }

########################################################################################################################################################
# Setting variables for installation folders for automated service installation and custom scripts
# 
#

WorkingDirectoryBot="${_dir}/${BinanceFolder}/binance-trade-bot"
WorkingDirectoryTelegram="${_dir}/${BinanceFolder}/BTB-manager-telegram"
DescriptionBot="Binance Trade Bot - ${BinanceFolder}"
DescriptionTelegram="BTB-manager-telegram - ${BinanceFolder}"

########################################################################################################################################################
# Start Custom script section
# Create custom script folder and custom script file for BTB manager Telegram
# Scripts created by Onicniepytaj
#
mkdir -p ${WorkingDirectoryTelegram}/custom_scripts

##################################################################
# Create Custom Script file, which will be called in telegram bot
#
cat <<EOF >${WorkingDirectoryTelegram}/config/custom_scripts.json
{
  " Current coin progress": "custom_scripts/current_coin_progress.sh",
  " All coins progress": "custom_scripts/all_coins_progress.sh",
  "隸 Appreciate Masa": "echo Masa is great"
}
EOF


##################################################################
# Create Current_coin_progress.sh file
#
cat <<'EOF' >${WorkingDirectoryTelegram}/custom_scripts/current_coin_progress.sh
#!/bin/bash
sqlite3 -cmd '.timeout 1000' ../binance-trade-bot/data/crypto_trading.db "select id,alt_trade_amount, datetime, alt_coin_id from trade_history where selling=0 and state='COMPLETE' and alt_coin_id=(select alt_coin_id from trade_history order by id DESC limit 1);" > results
starting_value=$(sed -n '1p' results| awk -F\| '{print $2}')
while read p; do
   echo -n "Trade no: "
   echo $p | awk -F\| '{print $1}'
   echo -n "Hodlings: "
   echo $p | awk -F\| '{print $2}'
   echo -n "Date: "
   echo $p | awk -F\| '{print $3}'
   echo -n "Grow: "
   value=$(echo $p | awk -F\| '{print $2}')
   grow=$(awk "BEGIN {print ($value/$starting_value*100)-100}")
   echo -n $grow
   echo "%"
   echo
done <results

echo -n "Current coin: "
echo $(sed -n '1p' results| awk -F\| '{print $4}')
EOF
sudo chmod +x ${WorkingDirectoryTelegram}/custom_scripts/current_coin_progress.sh

##################################################################
# Create all_coin_progress.sh file
#
cat <<'EOF' >${WorkingDirectoryTelegram}/custom_scripts/all_coins_progress.sh
#!/bin/bash
DATABASE=../binance-trade-bot/data/crypto_trading.db
while read p; do
   echo -n "Coin: "
   echo $p
   jumps=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select count(id) from trade_history where alt_coin_id='$p' and selling=0 and state='COMPLETE';")
   if [[ $jumps -gt 0 ]]
   then
	first_date=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select datetime from trade_history where alt_coin_id='$p' and selling=0 and state='COMPLETE' order by id asc limit 1;")
	echo -n "First coin bought at: "
	echo $first_date
     echo -n "Starting value: "
     first_value=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select alt_trade_amount from trade_history where alt_coin_id='$p' and selling=0 and state='COMPLETE' order by id asc limit 1;")
     echo $first_value
     echo -n "Last value: "
     last_value=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select alt_trade_amount from trade_history where alt_coin_id='$p' and selling=0 and state='COMPLETE' order by id DESC limit 1;")
     echo $last_value
     echo -n "Grow: "
     grow=$(awk "BEGIN {print ($last_value/$first_value*100)-100}")
     echo -n $grow
     echo "%"	
	echo -n "Starting value: "
	crypto_coin_id=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select crypto_coin_id from trade_history where alt_coin_id='$p' and selling=0 and state='COMPLETE' order by id asc limit 1;")
	first_value2=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select crypto_trade_amount from trade_history where alt_coin_id='$p' and selling=0 and state='COMPLETE' order by id asc limit 1;")
	echo -n $first_value2
     echo -n " "
     echo $crypto_coin_id
     echo -n "Last value: "
     last_value2=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select crypto_trade_amount  from trade_history where alt_coin_id='$p' and selling=0 and state='COMPLETE' order by id DESC limit 1;")
     echo -n $last_value2
     echo -n " "
     echo $crypto_coin_id
     echo -n "Grow: "
     grow=$(awk "BEGIN {print ($last_value2/$first_value2*100)-100}")
     echo -n $grow
     echo "%"
	echo -n "Number of trades: "
	echo $jumps
   else
     echo "Coin has not yet been bought"
   fi
     echo
done <../binance-trade-bot/supported_coin_list
EOF
sudo chmod +x ${WorkingDirectoryTelegram}/custom_scripts/all_coins_progress.sh

# End Custom script section
########################################################################################################################################################


