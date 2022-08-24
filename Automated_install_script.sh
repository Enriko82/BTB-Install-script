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
# Set here in which folder you would like the Bot to be installed:
# By default the bot will be installed in the subfolder Binance1
BinanceFolder=Binance1
#
# Update in the end of this file below the following chapters, by completing the data needed
# 1) Fill in below your user.cfg details.
# 2) Fill in below your supported coins, which you would like to trade
# 3) Fill in below your Telegram Bot ID's
# The telegram bot currently supports multiple languages. Default is en (English). New are fr(ench) or ru(ssian)
# https://github.com/lorcalhost/BTB-manager-telegram#language-setting
TGLang=en
# Run the following commands in the SSH client
# For ubuntu shape the following must be done first:
# 				sudo apt-get update
# 				sudo apt-get install vim
# After that if VI is installed:
# 		vi start.sh
# Press insert or i to go into edit mode
# Copy everything from this file into the VI screen. (Right mouse click and paste)
# Press Esc button and Shift + ZZ
# 		sudo chmod +x start.sh
# 		./start.sh
# if you want to install more bots, then update the Binancefolder variable, user.cfg, Supported coin list and apprise.yml section
# and update start.sh to eg start2.sh
# The script should run now and will ask you 2 questions
# 1) Which Bot or Fork you would like to install
# 2) On which system you will install it
#
# If you like this automated install script. Please go to:
# https://www.buymeacoffee.com/Enriko82
#
#
## Version updates
# 1.0 17-05-2021
# 1.1 23-05-2021 Updated working directory of BTB manager-telegram
# 1.2 28-05-2021 Updated Oracle cloud to Oracle Linux cloud, updated user.cfg InstallScript=Enriko82_V1.2_20210528
# 1.3 31-05-2021 Added NTP synch, added custom scripts of Onicniepytaj
# 1.4 02-06-2021 Added TnTwist version as option, Updated binance user cfg for TnTwist version, added BinanceBotVersion=%Chosen version% for documentation
# 1.5 06-06-2021 Added current install directory, Retrieve Username, added sqlite3 support
# 1.6 09-06-2021 Added installation on Oracle Linux Cloud (VM.Standard.A1.Flex) up to 4 CPU and 24 GB of RAM
# 1.7 10-06-2021 Added TA-Lib preparation, added Mila432 (Homersimpson) version
# 1.8 23-06-2021 Added Oracle Ubuntu 20.04 (python 3.8.5) which can include TA-Lib and Mathlab for Crypto charts
# 1.9 27-06-2021 Bugfixes of variable. Added warmup in custom script.
# 1.10 13-09-2021 Commented out TAlib install. Merged fix for database warmup and restorecon of services
# 1.11 22-11-2021 Added multi language support for Telegram and auto startup. Updated user.cfg default variables.
# 1.12 11-12-2021 Added MasaiasuOse to the selectable forks
#
Installversion=Enriko82_Full_1.12_11-12-2021 
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
# 
#
PS3='Please enter your choice: '
options=("Edeng32 Master" "Idkravitz master" "TnTwist master" "Mila432 (Homersimpson) master" "MasaiasuOse master" "Specific Branch" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Edeng32 Master")
		BinanceBot="git clone https://github.com/edeng23/binance-trade-bot.git"
        	BinanceBotVersion="Edeng 23 Master"
		echo "Binance trading bot will be installed with ${BinanceBot}"
            	break
			;;
        "Idkravitz master")
            	BinanceBot="git clone https://github.com/idkravitz/binance-trade-bot.git"
        	BinanceBotVersion="Idkravitz master"
		echo "Binance trading bot will be installed with ${BinanceBot}"
		break
           ;;   
        "TnTwist master")
            	BinanceBot="git clone https://github.com/tntwist/binance-trade-bot.git"
        	BinanceBotVersion="TnTwist master"
		echo "Binance trading bot will be installed with ${BinanceBot}"
		break
           ;;
        "Mila432 (Homersimpson) master")
            	BinanceBot="git clone https://github.com/Mila432/binance-trade-bot.git"
        	BinanceBotVersion="Mila432 (Homersimpson) master"
		echo "Binance trading bot will be installed with ${BinanceBot}"
		break
           ;;	   
		"MasaiasuOse master")
            	BinanceBot="git clone https://github.com/MasaiasuOse/binance-trade-bot.git"
        	BinanceBotVersion="MasaiasuOse master"
		echo "Binance trading bot will be installed with ${BinanceBot}"
		break
           ;;   
        "Specific Branch")
		BinanceBot="git clone -b websockets-idkravitz --single-branch https://github.com/idkravitz/binance-trade-bot.git"
        	BinanceBotVersion="Specif branch"
           	echo "Binance trading bot will be installed with ${BinanceBot}"
		break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

########################################################################################################################################################
# Install type choice

PS4='Please enter your choice: '
options1=("Oracle Linux Cloud" "Oracle Linux Cloud (VM.Standard.A1.Flex)" "Oracle Ubuntu" "Raspberry Pi" "Manual (Other)" "Quit")
select opt in "${options1[@]}"
do
    case $opt in
        "Oracle Linux Cloud")
			UserBot="$USER"
			echo "User name is ${UserBot}"
			################################
			#Default Kernel updates and mandatory software installation
			#
			PATH=$PATH:/home/${UserBot}/.local/bin;export $PATH
			sudo yum update -y 
			sudo -H pip3 install --upgrade pip
			sudo yum install git sqlite3 ntp python-devel python36-devel openssl-devel libffi-devel libevent-devel -y
			pip install cryptography==3.2.1
			pip install pyOpenSSL==19.1.0
			pip install python-dateutil==3.0.0
			pip install configparser==4.0.2
			break
			;;
	"Oracle Linux Cloud (VM.Standard.A1.Flex)")
			UserBot="$USER"
			echo "User name is ${UserBot}"
			################################
			#Default Kernel updates and mandatory software installation
			#
			PATH=$PATH:/home/${UserBot}/.local/bin;export $PATH
			sudo yum update -y 
			sudo pip3 install --upgrade pip
			pip3 install oci-cli --upgrade
			pip3 install python-dateutil
			sudo yum install git sqlite ntp python-devel python36-devel openssl-devel libffi-devel libevent-devel -y
			pip3 install wheel
			break
			;;
	"Oracle Ubuntu")
			#Setting current username for services
			UserBot="$USER"
			# below variable will install Cryptochart
			PyVer38="Yes"
			echo "User name is ${UserBot}"
			PATH=$PATH:/home/${UserBot}/.local/bin;export $PATH
			sudo apt update -y
			sudo apt-get update -y
			sudo apt install ntp git python3 idle3 python3-pip sqlite3 -y
			pip install websockets==8.1
			break
			;;
	"Raspberry Pi")
            		UserBot="$USER"
			# below variable will install Cryptochart if set to Yes and Python version is 3.8 or higher
			PyVer38="No"
			echo "User name is ${UserBot}"
			PATH=$PATH:/home/${UserBot}/.local/bin;export $PATH
			sudo apt update
			sudo apt-get update
			sudo apt install ntp -y
			sudo apt install git python3 idle3 python3-pip sqlite3 -y
			break
           ;;
        "Manual (Other)")
            		#Setting current username for services
			UserBot="$USER"
			echo "User name is ${UserBot}"
			echo Following updates are not tested!
			sleep 10s 
			PATH=$PATH:/home/${UserBot}/.local/bin;export $PATH
			sudo apt update
			sudo apt-get update
			sudo apt install ntp -y
			sudo apt install git python3 idle3 python3-pip sqlite3
			break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

########################################################################################################################################################
## If $1 is not passed, set to the current working dir using $PWD
# Set current directory as install directory
_dir="${1:-${PWD}}"
 
## Die if $dir does not exists
[ ! -d "$_dir" ] && { echo "Error: Directory $_dir not found."; exit 2; }
 
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


##################################################################
# Check if TA-lib is needed. If yes then prepare data. Works only with Python 3.7+
# Removed temporary as it is not installing correctly
# if grep -iFq "TA-lib" "${WorkingDirectoryBot}/requirements.txt" ; then
# echo "Downloading TA-lib files"
# wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
# tar -xzf ta-lib-0.4.0-src.tar.gz
# cd ta-lib/
# ./configure --prefix=/usr
# make
# sudo make install
# pip3 install TA-Lib
# cd ..
# fi
# End TA-Lib preperation 
##################################################################
# Install requirements of bots
cd binance-trade-bot
pip3 install -r requirements.txt
cd ..
cd BTB-manager-telegram
pip3 install -r requirements.txt
cd ..


########################################################################################################################################################
# Start Custom script section
# Create custom script folder and custom script file for BTB manager Telegram
# Scripts created by Onicniepytaj
#
mkdir -p ${WorkingDirectoryTelegram}/custom_scripts


if test ${PyVer38} = "Yes"
then
git clone https://github.com/marcozetaa/binance-chart-plugin-telegram-bot.git
# Create config file for Binance chart plugin
cat <<EOF >${WorkingDirectoryBTBChart}/config
[config]
bot_path=${WorkingDirectoryBot}
min_timestamp = 0
EOF
cd binance-chart-plugin-telegram-bot
pip3 install -r requirements.txt
##################################################################
# Create Custom Script file, which will be called in telegram bot
#
cat <<EOF >${WorkingDirectoryTelegram}/config/custom_scripts.json
{
  "💰 Current coin progress": "custom_scripts/current_coin_progress.sh",
  "💰 All coins progress": "custom_scripts/all_coins_progress.sh",
  "🦸 Appreciate Masa": "echo Masa is great",
  "Crypto chart": "python3 ../binance-chart-plugin-telegram-bot/db_chart.py",
  "Update crypto chart": "bash -c 'cd ../binance-chart-plugin-telegram-bot && git pull'",
  "Database warmup": "cd ../binance-trade-bot && python3 database_warmup.py"
}
EOF
else
##################################################################
# Create Custom Script file, which will be called in telegram bot for non Ubuntu setups
#
cat <<EOF >${WorkingDirectoryTelegram}/config/custom_scripts.json
{
  "💰 Current coin progress": "custom_scripts/current_coin_progress.sh",
  "💰 All coins progress": "custom_scripts/all_coins_progress.sh",
  "🦸 Appreciate Masa": "echo Masa is great",
   "Database warmup": "cd ../binance-trade-bot && python3 database_warmup.py"
}
EOF
fi

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
ExecStart=/usr/bin/python3 -u -m binance_trade_bot
WorkingDirectory=${WorkingDirectoryBot}
StandardOutput=inherit
StandardError=inherit
Restart=on-failure
User=${UserBot}

[Install]
WantedBy=multi-user.target
EOF
sudo mv BTB${BinanceFolder}.service /etc/systemd/system/BTB${BinanceFolder}.service
restorecon /etc/systemd/system/BTB${BinanceFolder}.service
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
ExecStart=/usr/bin/python3 -u -m btb_manager_telegram -s -p "../binance-trade-bot" -l ${TGLang}
WorkingDirectory=${WorkingDirectoryTelegram}
StandardOutput=inherit
StandardError=inherit
Restart=always
User=${UserBot}

[Install]
WantedBy=multi-user.target
EOF
sudo mv BTBTelegram${BinanceFolder}.service /etc/systemd/system/BTBTelegram${BinanceFolder}.service
restorecon /etc/systemd/system/BTBTelegram${BinanceFolder}.service
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
api_key=vmPUZE6mv9SD5VNHkasf324232zvsw0MuIgu91duEh8A
api_secret_key=NhqPtmdSJYdKjVHjA7asdfasd333R5YNiP1e3UZjInClVN65XAj0j
current_coin=
bridge=USDT
tld=com
hourToKeepScoutHistory=1
use_margin=no
scout_multiplier=5
scout_margin=0.8
scout_sleep_time=1
strategy=multiple_coins
buy_timeout=10
sell_timeout=10
buy_order_type=limit
sell_order_type=market
#AdditionalParameters=Below_is_only_for_TnTwist_Master
enable_paper_trading=False
sell_max_price_change=0.005
buy_max_price_change=0.005
trade_fee=auto
price_type=orderbook
auto_adjust_bnb_balance=false
auto_adjust_bnb_balance_rate=3
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
BTTC
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
- tgram://TOKEN/CHAT_ID
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
