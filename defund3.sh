#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
DEFUND_PORT=40
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export DEFUND_CHAIN_ID=defund-private-3" >> $HOME/.bash_profile
echo "export DEFUND_PORT=${DEFUND_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

# download binary
cd $HOME && rm -rf defund
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.2.1
make install

# config
defundd config chain-id $DEFUND_CHAIN_ID
defundd config keyring-backend test
defundd config node tcp://localhost:${DEFUND_PORT}657

# init
defundd init $NODENAME --chain-id $DEFUND_CHAIN_ID

# download genesis and addrbook
wget -O defund-private-3-gensis.tar.gz https://github.com/defund-labs/testnet/raw/main/defund-private-3/defund-private-3-gensis.tar.gz
sudo tar -xvzf defund-private-3-gensis.tar.gz -C $HOME/.defund/config
rm defund-private-3-gensis.tar.gz

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ufetf\"/" $HOME/.defund/config/app.toml

# set peers and seeds
SEEDS="85279852bd306c385402185e0125dffeed36bf22@38.146.3.194:26656,09ce2d3fc0fdc9d1e879888e7d72ae0fefef6e3d@65.108.105.48:11256,9aa8a73ea9364aa3cf7806d4dd25b6aed88d8152@defund.seed.mzonder.com:10756"
PEERS="03d46eae18d935a2e820735563ab01abb17d4cb6@65.108.235.107:29656,081a38c22f5c1915c3c38b529ef112370b45e290@161.97.91.80:26656,0cccc6e27f4aaf1f339905f8ad6a589467aeecc7@43.155.61.87:26656,80999d2aa81628c07454cc8ad4925fc6b44bdde0@206.217.140.82:26656,8715ed67b8833997d8cbfba985dbfc389a5a45dc@43.154.103.36:26656,5a1d2ab416788f41da94e3d993aeefba4618c288@192.210.206.198:26656,41a997be04de03c085f02073cdda4192f48c8330@216.127.190.109:26656,dfba70b73435b2540ebfa953cb1ca32193a957e6@43.159.194.246:26656,65e5fd83df6e42e686503f44dc0c685f722fa02a@43.154.53.71:26656,263616dba779061a18ded71dddb92928ea27a4ba@43.154.83.15:26656,e108c39c307864acbeceda3f4b2c77c99ec1bddd@185.16.38.136:36656,e4677ff91a0bfec8949de0c2d531b4bbffcb0ceb@92.119.112.231:36656,85b021ed71173a0825736891b06592a8eee7b4ca@43.156.112.45:26656,bdcaabb2384b1a59d12fbd57dd1d74a58edaf1b2@175.24.183.235:26656,45b50b7ad8df4d2661fc6f510bd9d490b5ec253d@43.134.202.178:26656,43452645f84db6827452f32869ddf3ce585937c5@43.156.111.103:26656,257de7d6825037b6c6de16aac4ebb9efd641b8a6@43.156.111.241:26656,58aef46a0286a6d50a7f687bfc35d62f85feec10@107.174.63.166:26656,c8fb3ab19dfac9f75085cb5e4fff36845773d8a6@43.154.60.157:26656,77b3dcacd513f7f7fa1b0247d716f464ad61e94d@65.109.65.210:34656,966e31c78c08aae8c74aa12702126141fb9cef7a@185.165.240.179:24666,92b164431c37b1b8e8cb66cbabcd688108c7479c@43.130.228.99:26656,38d23d7332b035eae29ba0abda13d32906c78c09@65.108.159.90:26656,ce62e6e53805ceae1f8f1087c5f7f6da13049cec@43.130.242.40:26656,53e2240528947ff8f7b037d347b7258f05ce88f0@89.179.68.98:27656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.defund/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.defund/config/app.toml

# set custom ports
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${DEFUND_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${DEFUND_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${DEFUND_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DEFUND_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${DEFUND_PORT}660\"%" $HOME/.defund/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${DEFUND_PORT}317\"%; s%^address = \":8080\"%address = \":${DEFUND_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${DEFUND_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${DEFUND_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${DEFUND_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${DEFUND_PORT}546\"%" $HOME/.defund/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.defund/config/config.toml

# reset
defundd tendermint unsafe-reset-all --home $HOME/.defund

# create service
sudo tee /etc/systemd/system/defundd.service > /dev/null <<EOF
[Unit]
Description=defund service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which defundd) start --home $HOME/.defund
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable defundd
sudo systemctl restart defundd

break
;;

"Create Wallet")
defundd keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
DEFUND_WALLET_ADDRESS=$(defundd keys show $WALLET -a)
DEFUND_VALOPER_ADDRESS=$(defundd keys show $WALLET --bech val -a)
echo 'export DEFUND_WALLET_ADDRESS='${DEFUND_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export DEFUND_VALOPER_ADDRESS='${DEFUND_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
defundd tx staking create-validator \
  --amount 2000000ufetf \
  --from $WALLET \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(defundd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id $DEFUND_CHAIN_ID
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
