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
echo "export DEFUND_CHAIN_ID=defund-private-4" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.19.4"
  cd $HOME
wget -O go1.19.4.linux-amd64.tar.gz https://golang.org/dl/go1.19.4.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.4.linux-amd64.tar.gz && sudo rm go1.19.4.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
fi

# download binary
cd $HOME && rm -rf defund
git clone https://github.com/defund-labs/defund.git
cd defund
git checkout v0.2.2
make install

# config
defundd config chain-id $DEFUND_CHAIN_ID
defundd config keyring-backend test

# init
defundd init $NODENAME --chain-id $DEFUND_CHAIN_ID

# download genesis and addrbook
cd $HOME/.defund/config
curl -s https://raw.githubusercontent.com/defund-labs/testnet/main/defund-private-4/genesis.json > ~/.defund/config/genesis.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ufetf\"/" $HOME/.defund/config/app.toml

#optimize
sed -i 's/max_num_inbound_peers =.*/max_num_inbound_peers = 150/g' $HOME/.defund/config/config.toml
sed -i 's/max_num_outbound_peers =.*/max_num_outbound_peers = 150/g' $HOME/.defund/config/config.toml
sed -i 's/max_packet_msg_payload_size =.*/max_packet_msg_payload_size = 10240/g' $HOME/.defund/config/config.toml
sed -i 's/send_rate =.*/send_rate = 20480000/g' $HOME/.defund/config/config.toml
sed -i 's/recv_rate =.*/recv_rate = 20480000/g' $HOME/.defund/config/config.toml
sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $HOME/.defund/config/config.toml
sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $HOME/.defund/config/config.toml
sed -i 's/timeout_commit =.*/timeout_commit = "100ms"/g' $HOME/.defund/config/config.toml
sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $HOME/.defund/config/config.toml

# set peers and seeds
SEEDS="d837b7f78c03899d8964351fb95c78e84128dff6@174.83.6.129:30791,f03f3a18bae28f2099648b1c8b1eadf3323cf741@162.55.211.136:26656,f8fa20444c3c56a2d3b4fdc57b3fd059f7ae3127@148.251.43.226:56656,70a1f41dea262730e7ab027bcf8bd2616160a9a9@142.132.202.86:17000"
PEERS="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656,f8093378e2e5e8fc313f9285e96e70a11e4b58d5@141.94.73.39:45656,fb73921dc5bf1e939308eaa37053c12bd647852b@45.147.199.210:26656,3393cfd5d08561f019b2cd6ce076c3e63102baf6@65.108.105.48:11256,2ebcf1ea3fc2e3ef10b2564e5b76918b05f2f4b6@65.108.140.220:27656,e26b814071e94d27aa5b23a8548d69c45221fe28@135.181.16.252:26656,0e1c7faddb695725cd5f23603fa6b654ece91da1@65.109.106.179:11256,b6849dcff65d91bc9376366d788cd958a6e0f5df@45.147.199.174:26656,9389cefdaa999eb81b93f4354d1077553ceb7a86@217.76.55.76:26656,2c57fc71ccb618acd7823422afaa78bffb8550cd@65.109.93.152:31256,9caa4ac64062fa1178a9db93d24209841bbd30ba@199.175.98.110:26656,149363085e1ea7b9687b7a20dd8e4847d56ba22f@65.21.121.101:26656,2a87e54d6849058523a0d761318cb1258c4299df@77.91.123.14:26656,d99bc0d33e96fee388f6f5df5ee5b827a59c8560@57.128.144.242:26656,e23c5cf49a734617dba5d10573b53ecd3f3265ee@194.180.176.124:26656,f02544ad936678f3c6f23897daee2c807b3d293c@45.147.199.188:26656,88232417b05f9e1f3cd6ff9fa3296219d577dee4@185.144.99.73:26656,b9a22be1f13a4ed99de4ecdd4c9e2a9e4711c2ac@45.147.199.190:26656,b7f7e07958425af3848b09cd909c1e5aff709224@91.77.165.172:61356,a9c4e48255c73cf49ea0459ef89c9c0a9ce9de80@65.108.240.79:26656,d9695d9eec0915e165824258f4f97c23ae761da6@194.4.48.96:26656,cd3b0c2a3c5c7ae0f8f87a7d2346961698571219@65.108.14.216:27656,c7617e0de4986c28be878833290197229b96b4f0@181.214.147.81:18656,8809c1c07534b5fc6802eecdc810c5a39263e6b5@45.140.147.117:26656,36909ce5289d8f994fb2562f7a188a79ce826359@141.95.145.41:27656,0544670a43be0a61c7e354bc55d32b6573dc31cf@94.131.106.79:26656,c1d2c7a810c386595e59ead21ba69555a37ac007@5.161.110.128:26656,7831e762e13c2cb99236b59f5513bf1f8d16d036@88.99.3.158:10356,e73a8c70a1e55c4ee14874c659a9084773ea56ed@168.119.227.28:36656,b32e6619a1c7998519d2d38828e34ace7b773852@65.109.84.250:26656,9ef4a86e3981b53c8da75051a077489ad77cb4ba@5.75.138.108:26656,2b76e96658f5e5a5130bc96d63f016073579b72d@51.91.215.40:45656,69eb13f2e9865f58cd8b225fd1e8b6e6b8c7911a@45.147.199.199:26656,7b51e20c06587e6ba9d4b179ef579da461a0a3c5@65.108.238.217:11144,b71709ea71ec571ddce864134034268e8c46d4fb@146.19.24.142:16656,6999cca6c55576a48d4f227b87dc904fbdb085aa@65.21.134.202:26576,b136caf667b9cb81de8c1858de300376d7a0ee0f@65.21.53.39:46656,468d11101fd224836238b0bc2bec55356cd11a49@65.109.92.148:60556,c584a5f8c28c7548752fdfea6cf2942d5e10c82e@188.34.178.190:36656,7e936b2c89d1d1a757d262bc64f981ed48fb50ec@65.21.3.229:26656,a9c52398d4ea4b3303923e2933990f688c593bd8@157.90.208.222:36656,6055a3838b18ee26adb28beda795d858d7254c11@45.147.199.206:26656,2a138efb5ef0638386af44c3df32ccdc8895b4d0@65.21.172.60:36656,7f70ef7884bb4a206442365f8b280ed259fd523c@65.109.85.225:7030,16af5142a97d6bd22f941c15ad8faf2150d48e59@157.90.157.18:26656,8577f82b37e09c3e15e6852697107019b04c0679@217.76.55.70:26656,4eb0bef7997b87086c40766193d812479238187c@217.76.55.66:26656,d006dda2f424971bb8d3cc2bd891709403804da6@75.119.147.235:26656,5ac40e96d9194536e15a28a1010551300cbab616@185.216.75.21:26656,edabbcbfb21c488be785f0925b0060c717440bad@92.119.112.229:26656,b6c474b89a8913f0907f816e5ac01886bc3f3896@154.26.128.99:36656,3f472746f46493309650e5a033076689996c8881@65.109.68.190:40659"
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
defundd tendermint unsafe-reset-all

SNAP_NAME=$(curl -s https://snapshots3-testnet.nodejumper.io/defund-testnet/ | egrep -o ">defund-private-4.*\.tar.lz4" | tr -d ">")
curl https://snapshots3-testnet.nodejumper.io/defund-testnet/${SNAP_NAME} | lz4 -dc - | tar -xf - -C $HOME/.defund

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
  --amount 1000000ufetf \
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
