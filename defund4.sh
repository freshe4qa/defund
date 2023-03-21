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
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export DEFUND_CHAIN_ID=orbit-alpha-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt update && sudo apt upgrade -y
sudo apt install curl build-essential git wget jq make gcc tmux chrony lz4 unzip -y

# install go
cd $HOME
wget -O go1.19.1.linux-amd64.tar.gz https://golang.org/dl/go1.19.1.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.1.linux-amd64.tar.gz && rm go1.19.1.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile

# download binary
cd $HOME && rm -rf defund
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.2.6
make install

# config
defundd config chain-id $DEFUND_CHAIN_ID
defundd config keyring-backend test

# init
defundd init $NODENAME --chain-id $DEFUND_CHAIN_ID

# download genesis and addrbook
curl -s https://raw.githubusercontent.com/defund-labs/testnet/main/orbit-alpha-1/genesis.json > ~/.defund/config/genesis.json
curl -s https://snapshots2-testnet.nodejumper.io/defund-testnet/addrbook.json > $HOME/.defund/config/addrbook.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001ufetf\"/" $HOME/.defund/config/app.toml

#optimize
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 150/g' $HOME/.defund/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 150/g' $HOME/.defund/config/config.toml
sed -i 's/max_packet_msg_payload_size =.*/max_packet_msg_payload_size = 10240/g' $HOME/.defund/config/config.toml
sed -i 's/send_rate =.*/send_rate = 20480000/g' $HOME/.defund/config/config.toml
sed -i 's/recv_rate =.*/recv_rate = 20480000/g' $HOME/.defund/config/config.toml
sed -i 's/timeout_prevote =.*/timeout_prevote = "130ms"/g' $HOME/.defund/config/config.toml
sed -i 's/timeout_precommit =.*/timeout_precommit = "130ms"/g' $HOME/.defund/config/config.toml
sed -i 's/timeout_commit =.*/timeout_commit = "130ms"/g' $HOME/.defund/config/config.toml
sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $HOME/.defund/config/config.toml

# set peers and seeds
SEEDS="f902d7562b7687000334369c491654e176afd26d@170.187.157.19:26656,2b76e96658f5e5a5130bc96d63f016073579b72d@rpc-1.defund.nodes.guru:45656"
PEERS="fd3353908a1e3eedb019451b2e55054bca2e5303@defund-testnet.nodejumper.io:28656,60c436fe89d11b5a19100bea5097f1bc7ef40f66@95.216.14.58:60956,f9fcb1705d112b357fa498bb0711e2f4953d3f88@85.10.202.135:40656,2a0d9a217a96dbe7f5bc9fccff8b50da29f41f52@5.9.147.185:18656,18921a27facf3760d59147e4ae176b1bdf226346@195.201.237.172:18656,7c459f88962a4d07d7ccd6d0c94f891bb7a7ada0@65.109.26.21:13656,c0098c96773cbd0d7507d037768845c582f1a878@65.108.202.230:27656,91bbf1434b741862e406ab87c014fdff3cc96109@77.232.40.71:26656,e3c348467a8c88c0f65e2ca8a71875d2a384b8b4@185.16.39.19:60656,0484eab6881ba458c5988296403963aaf273700b@157.90.236.25:18656,7d988c0b027cb08ccda631c5c4eb65e2a543f393@144.76.164.139:13656,854cfaf6fd4de846fd020fbd7d0b5364c6fb9c58@65.21.95.46:27656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:40656,436a10ea3a057eb86a7a2e33208634b677a90de1@212.232.52.212:26656,1ad8ca05d8e58cbbae2deffa22068d730e1afe39@164.68.127.58:26656,a3ede88696b2b5f752129889b84b9292a168133a@142.132.152.46:21656,bfef03639bddf4fa503bb75c83af2b5f12c8276c@161.97.155.154:26656,da7e109ceb4376c812267062fddf98f01ec834df@40.83.10.226:26656,31b49e981e804cac50a092468e746e496740153e@65.109.84.254:26656,04e0d6c420f087bb619d957637bf849280f4a70d@94.131.11.166:26656,f114c02efc5aa7ee3ee6733d806a1fae2fbfb66b@5.9.147.22:25656,74e6425e7ec76e6eaef92643b6181c42d5b8a3b8@65.108.231.124:18656,3f2b1ce13248281f25712c2b69fde573c5d8effb@178.207.49.74:26656,2dbf17b447b86f551460a9b131550e9c1aedabfe@89.22.231.244:26656,5b3a2c084f0694b18fbfe560819cfbf3040ac24c@154.53.63.158:30656,cf61d5575997b6a67ecc71738a8c3516ce2576c4@144.91.93.32:30656,a8bd3dbc18a1403c7899ba46f82fcc73f1db73ee@65.108.6.45:60556,c806a2e792811afb419c9ff8edd793369c722394@5.161.198.224:26656,3209ec925afead6706ac250aae88d1b85a45a2d3@167.86.85.247:30656,d9516be6f5fffad9d2fa4354126c46ca5a6c9310@154.53.55.128:30656,c9407d06e8645e860eba3ab2d2340e0d9a74c294@62.171.138.196:30656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.defund/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.defund/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.defund/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.defund/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.defund/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.defund/config/config.toml

# create service
sudo tee /etc/systemd/system/defundd.service > /dev/null << EOF
[Unit]
Description=Defund Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which defundd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

# reset
defundd tendermint unsafe-reset-all --home $HOME/.defund --keep-addr-book 
curl https://snapshots2-testnet.nodejumper.io/defund-testnet/orbit-alpha-1_2023-03-21.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.defund

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
--amount=10000000ufetf \
--pubkey=$(defundd tendermint show-validator) \
--moniker $NODENAME \
--chain-id=orbit-alpha-1 \
--commission-rate=0.1 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.05 \
--min-self-delegation=1 \
--fees=2000ufetf \
--from $WALLET \
-y
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
