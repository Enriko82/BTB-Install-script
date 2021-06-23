#!/bin/bash
# This is an installation script for installing Binance Trade Bot on Oracle Free tier cloud.
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
#
# If you like this automated install script. Please go to:
# https://www.buymeacoffee.com/Enriko82
#
#
## Version updates
# 1.0 14-06-2021
#
# End instructions
########################################################################################################################################################

########################################################################################################################################################
# 
#
BinanceBot="git clone https://github.com/edeng23/binance-trade-bot.git"
BinanceBotVersion="Edeng 23 Master"
Installversion=Enriko82_Starter_1.0_20210614
#"Oracle Linux Cloud (VM.Standard.A1.Flex)")
			UserBot="opc"
			echo "User name is ${UserBot}"
			################################
			#Default Kernel updates and mandatory software installation
			#
			echo "Install directory ${BinanceFolder}"
			cd
			echo "Current location is $PWD"
			PATH=$PATH:/home/${UserBot}/.local/bin;export $PATH
			sudo yum update -y 
			sudo -H pip3.9 install --upgrade pip
			pip3.9 install oci-cli --upgrade
			pip3.9 install python-dateutil
			sudo yum install sqlite ntp python-devel python36-devel python39-devel openssl-devel libffi-devel libevent-devel -y
			pip3.9 install wheel
	
########################################################################################################################################################
## If $1 is not passed, set to the current working dir using $PWD
# Set current directory as install directory
_dir="${1:-${PWD}}"
 
## Die if $dir does not exists
[ ! -d "$_dir" ] && { echo "Error: Directory $_dir not found."; exit 2; }
echo "Bot will be installed in ${_dir}/${BinanceFolder}/"

########################################################################################################################################################
# Setting variables for installation folders for automated service installation 
# Custom scripts install is copied to for standalone installation: 
# https://github.com/Enriko82/BTB-Install-script/blob/main/BTB_Telegram_custom_Script.sh
# 
#

WorkingDirectoryBot="${_dir}/${BinanceFolder}/binance-trade-bot"
WorkingDirectoryTelegram="${_dir}/${BinanceFolder}/BTB-manager-telegram"
WorkingDirectoryBTBChart="${_dir}/${BinanceFolder}/binance-chart-plugin-telegram-bot"
DescriptionBot="Binance Trade Bot - ${BinanceFolder}"
DescriptionTelegram="BTB-manager-telegram - ${BinanceFolder}"

########################################################################################################################################################
#This will create the folder where the Binance Bot will be installed in.
#
mkdir $BinanceFolder
cd $BinanceFolder



########################################################################################################################################################
#This will install Git and install the BOTS
#
git init  
$BinanceBot
git clone https://github.com/lorcalhost/BTB-manager-telegram.git
git clone https://github.com/marcozetaa/binance-chart-plugin-telegram-bot.git
##################################################################
# Install requirements of bots
cd binance-trade-bot
pip3.9 install -r requirements.txt
cd ..
cd BTB-manager-telegram
pip3.9 install -r requirements.txt
cd ..
# Create config file for Binance chart plugin
cat <<EOF >${WorkingDirectoryBTBChart}/config
[config]
bot_path=${WorkingDirectoryBTBChart}
min_timestamp = 0
EOF
cd binance-chart-plugin-telegram-bot
pip3.9 install -r requirements.txt

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
  "💰 Current coin progress": "custom_scripts/current_coin_progress.sh",
  "💰 All coins progress": "custom_scripts/all_coins_progress.sh",
  "🦸 Appreciate Masa": "echo Masa is great",
  "Crypto chart": "python3.9 ../binance-chart-plugin-telegram-bot/db_chart.py",
  "Update crypto chart": "bash -c 'cd ../binance-chart-plugin-telegram-bot && git pull'"
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
     echo -n "Last value Buy/Sell: "
     last_valueb=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select crypto_trade_amount  from trade_history where alt_coin_id='$p' and selling=0 and state='COMPLETE' order by id DESC limit 1;")
     last_values=$(sqlite3 -cmd '.timeout 1000' $DATABASE "select crypto_trade_amount  from trade_history where alt_coin_id='$p' and selling=1 and state='COMPLETE' order by id DESC limit 1;")

     echo -n $last_valueb
     echo -n " / "
     echo -n " "
     echo -n $last_values
     echo $crypto_coin_id
     echo -n "Grow Buy/Sell: "
     growb=$(awk "BEGIN {print ($last_valueb/$first_value2*100)-100}")
     grows=$(awk "BEGIN {print ($last_values/$first_value2*100)-100}")
     echo -n $growb
     echo -n "% / "
     echo -n $grows
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



########################################################################################################################################################
# Start Service creation section
# This will create the Binance Bot services at startup
# Create a file BTB${BinanceFolder}.service with the following:
#

cat <<EOF >BTB${BinanceFolder}.service
[Unit]
Description=${DescriptionBot}
After=network.target

[Service]
ExecStart=/usr/bin/python3.9 -u -m binance_trade_bot
WorkingDirectory=${WorkingDirectoryBot}
StandardOutput=inherit
StandardError=inherit
Restart=on-failure
User=${UserBot}

[Install]
WantedBy=multi-user.target
EOF
sudo mv BTB${BinanceFolder}.service /etc/systemd/system/BTB${BinanceFolder}.service
sudo systemctl start BTB${BinanceFolder}.service
sudo systemctl enable BTB${BinanceFolder}.service


##################################################################
#This will create the telegram service at startup
#

cat <<EOF >BTBTelegram${BinanceFolder}.service
[Unit]
Description=${DescriptionTelegram}
After=network.target BTB${BinanceFolder}.service

[Service]
ExecStart=/usr/bin/python3.9 -u -m btb_manager_telegram -p "../binance-trade-bot"
WorkingDirectory=${WorkingDirectoryTelegram}
StandardOutput=inherit
StandardError=inherit
Restart=always
User=${UserBot}

[Install]
WantedBy=multi-user.target
EOF
sudo mv BTBTelegram${BinanceFolder}.service /etc/systemd/system/BTBTelegram${BinanceFolder}.service
sudo systemctl start BTBTelegram${BinanceFolder}.service
sudo systemctl enable BTBTelegram${BinanceFolder}.service

# End Service creation section
########################################################################################################################





################################################################################################################################################
# Start User parameters Fill in field section
# User parameter setup. Fill in your details here
# 1) Fill in below your user.cfg details.
# Update your API keys and your bridge coins. The rest can be kept as default
#
#
cat <<EOF >${WorkingDirectoryBot}/user.cfg 
[binance_user_config]
api_key=${api_key}
api_secret_key=${api_secret_key}
current_coin=
bridge=${bridge}
tld=com
hourToKeepScoutHistory=1
scout_multiplier=5
scout_sleep_time=1
strategy=multiple_coins
buy_timeout=10
sell_timeout=10
buy_order_type=limit
sell_order_type=market
#BinanceBotVersion=${BinanceBotVersion}
#BinanceBotInstallFolder=${BinanceFolder}
#InstallScript=${Installversion}
EOF

##################################################################
# 2) Fill in below your supported coins, which you would like to trade
# Note: EOF is not a coin, but End Of File for creating the Supported Coin List file
#
cat <<EOF >${WorkingDirectoryBot}/supported_coin_list
ADA
ATOM
BAT
BTT
DASH
EOS
ETC
ICX
IOTA
NEO
OMG
ONT
QTUM
TRX
VET
XLM
XMR
EOF

##################################################################
# 3) Fill in below your Telegram Bot ID's
#


cat <<EOF >${WorkingDirectoryBot}/config/apprise.yml
# Define version
version: 1
# Define your URLs (Mandatory!)
# URLs should start with - (remove the comment symbol #)
# Replace the values with your tokens/ids
# For example a telegram URL would look like:
# - tgram://123456789:AABx8iXjE5C-vG4SDhf6ARgdFgxYxhuHb4A/-606743502
urls:
- tgram://${TOKEN}/${CHAT_ID}
  # - discord://WebhookID/WebhookToken/
  # - slack://tokenA/tokenB/tokenC
  # More options here: https://github.com/caronc/apprise
EOF


#
# End User parameters Fill in field section
# End of script
###########################################################
echo "Press now ESC and then Shift + ZZ"
echo "Reboot your server with: sudo shutdown -r"
echo "Thanks for using the script of Enriko82"
sudo reboot
