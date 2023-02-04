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
git checkout v0.2.4
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
PEERS="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656,0f0bff656c744e471c20e30d0039a1a60d3e6bed@65.109.94.3:13656,36909ce5289d8f994fb2562f7a188a79ce826359@141.95.145.41:27656,7df04198931e556de89a8400a52e4fe8fc8bdfe3@65.108.60.172:26656,55f17385f722c2f9e84850b1da5bb72de927d9c6@65.108.72.233:34656,3991bd490f6c214f65ff9d244ea51f05c32fdbe7@92.39.210.164:26656,ce71fbdddab2181fa599b141b68dad069356f2dd@65.109.135.20:26656,4e5ee7d28400d73f009ce4e215a00ce8744927d7@38.242.139.92:26656,c7617e0de4986c28be878833290197229b96b4f0@181.214.147.81:18656,6fe5e0e9430ff243d122a3ffcff795c63cd370b2@109.123.251.149:26656,8979ab8debce119007bf90536a23378c61e709ff@84.54.23.56:26656,384d60222f6c24f962b530d5e4ee536dfba6269f@143.198.129.247:26656,35cc34b214e52d98e8ab7c8f4b6aba0017c2347a@158.69.6.144:40656,78f577049908ad58e3ea613855e55fbbd3f546de@207.180.233.65:30656,ad24fa713f19422cba774dd18aa6403e86d1e4b4@213.239.207.165:26756,206bd41fec86ae650c30ded9a460cbc2619d83d5@45.85.250.108:31656,149363085e1ea7b9687b7a20dd8e4847d56ba22f@65.21.121.101:26656,f02544ad936678f3c6f23897daee2c807b3d293c@45.147.199.188:26656,045202b03eff8179df3cea2282fbee8f4535836b@75.119.137.222:26656,470659b1b29f972f553433905dfa7ea389b243b3@185.246.84.44:26656,b32e6619a1c7998519d2d38828e34ace7b773852@65.109.84.250:26656,1a8ff63090146d206ddf253e0bbbb35a6134079d@65.21.141.246:27656,d7aba9c615b8a79446c670590f964de35d40959d@194.163.188.162:26656,9caa4ac64062fa1178a9db93d24209841bbd30ba@199.175.98.110:26656,0d560c5dedc7415c45d9a9a6c8f4c4b69b0d31cc@65.108.8.55:26656,4d3b57b07c9b28b6e41757b37b485b8482ed98d9@45.147.199.193:26656,ccc69309c5b72f7731b910920167c31143bf4e44@155.133.22.127:26656,ec741e0c5488405611e20ee8cb255f7933825880@65.109.93.242:13656,05f77cfaf0c5a5e70c8f861decef07ef4f85462f@109.205.180.95:26656,80d874c024e8a23e4a7b4e6d111e338d1d39f3e4@78.46.210.129:26656,83fb1a57ca8649112ecac1745a1b7f3fcff0cfd9@95.111.230.76:40656,67742399a48abc97c7eef61b1a60b96c720122c2@45.147.199.180:26656,23c22b887e2cd55de7eb491f43f52e8d6915e825@65.108.98.56:26656,b03f57e736985bc52fbdaef073908caf16e2ff6b@65.21.3.95:40656,9d98ffa5f8092368e6229efb1c2bc66e165af6c0@146.19.24.52:18656,9fc47f55128d84c8133fecf1aaee10df975041e2@199.175.98.108:26656,5ee260c0ff74f961404aa04f918f1eb73eba5393@217.76.49.112:26656,f2131bd9dddb5374aab56e63e1d7c19cfd1a77d1@161.97.81.81:26656,d097a86a2a51a8fd7ab078eef1d14884b41784df@45.147.199.202:26656,9c158ab5f71de2896b2ba2f1203d09734c77235d@129.146.80.192:34656,75a611e4037ad21736ebb6d499dd37f366fe5c24@65.108.41.168:26656,f5dc4f8bd04f2e18349487e922a7c8432a37aaec@164.68.103.181:26656,3a905af7f8050fd2c566dd324ed7303a70eff7db@194.180.176.125:26656,0176c2127c25f0ecd8383577cd373e0928d20884@86.48.3.14:26656,c46d3ae5dbba839a8323a895201f579ba9fb55eb@194.146.13.190:26656,9e1c29e75bf7dabdd43a27898148195d198a9aa0@23.88.70.109:18656,94abf10840eaebd1e2e576995a41fddbb6687497@185.219.142.198:26656,d3334ae0a1608e3418ba09a1f7a079163960a46f@38.242.235.216:26656,e4bdede18b0ae77a9c6d5c00f52a2a589f3ae4e2@194.233.67.92:40656,0892f7c227b060ce398940b4a302c2228f98f7c7@109.123.247.238:26656,fa6dca87ec79ff246dbe5460d6aa610a60e8df07@164.68.102.102:26656,c6345f83fe640c16dca7b6d7de4c47dd4094aaad@159.69.183.206:40656,acb1cae235743b149f96327fdffcb808f7987242@185.209.29.25:26656,bcabfc1a07e44350aad83752c0f34b76746c87a1@65.21.232.160:13656,0f25e490f15bdb3453d2f5a86344d4cd68411233@135.181.88.50:40656,fe1fe3318b450201b19827bbdf9d5aeb9ae2b916@107.155.91.166:31656,aed2e345687433f661777c3692784368da47c9f5@65.108.237.231:30656,0544670a43be0a61c7e354bc55d32b6573dc31cf@94.131.106.79:26656,5be1457d754b09987aa4e371f8181d646d59c8fd@95.217.202.49:33656,0ecf27e648de1564693299d5ae45c762478820cc@65.109.163.167:40656,3878480cc0cef573cd5f521a4475c25e386b3d46@173.249.54.237:40656,6999cca6c55576a48d4f227b87dc904fbdb085aa@65.21.134.202:26576,228caaf18704dac5c423f8a19e12a0d66c10d012@161.97.81.155:26656,7da687fa5a1f9a635fb333519582fcc6fdada112@23.88.74.54:40656,20045ce5bdc8fbc356d82351305fe2f9f188a4b5@217.76.55.68:26656,5311f766a533e923c0edbd30770c8939474d2ed0@65.109.173.25:26656,1c542289fefcd8d0794e6dc41216603014bf63b1@95.128.140.24:40656,5b6efed49f2d1d51a29a2a1fe5d40a5417aa8578@95.216.100.241:40656,a8b656506e69690bfa2c424f9ac2a58a99a920c1@161.97.77.186:26656,6bcb7d5f9d0515f6e5d7f63b8ca5fb2df1fc9232@65.109.3.8:26656,8d89260a0466ca45dc35967e6cce805934d7a2fb@65.108.140.109:33656,22ebabcd10c643b39ea51235a60cb99887da995d@95.214.53.105:26666,7924da435d769ef52cb0df0236d1ef5d1b9ba017@95.214.55.25:36656,2b76e96658f5e5a5130bc96d63f016073579b72d@51.91.215.40:45656,2a87e54d6849058523a0d761318cb1258c4299df@77.91.123.14:26656,f2bb49aff5b6748557410d3a2f7bbd9305cd9dc6@65.109.84.215:36656,0cd7099066dd5d57dd387d6bad53f2a38b11ecdd@77.232.43.32:26656,8ce02398652b4f4c953280ecd21949c4cf4a1414@167.86.105.64:26656,18921a27facf3760d59147e4ae176b1bdf226346@195.201.237.172:18656,e26b814071e94d27aa5b23a8548d69c45221fe28@135.181.16.252:26656,20d7ec2a2813200cb70fd0bc4a90f7ef257ffc49@95.216.2.219:21656,cb503107b4135363d5ff83ff6a1a1423d8db4166@62.171.169.230:40656,a78c5a1fa7b12eef729fa3dec3b7c3b073552664@45.147.199.191:26656,468d11101fd224836238b0bc2bec55356cd11a49@65.109.92.148:60556,d9695d9eec0915e165824258f4f97c23ae761da6@194.4.48.96:26656,4d3b782ab389525370f53d40e970b1362bc92106@185.182.186.202:26656,ec9c0e3cf6c7d96422c6bb8f6e610826a377fe51@65.109.164.58:26656,28f14b89d10992cff60cbe98d4cd1cf84b1d2c60@88.99.214.188:26656,4725abd8d2a813dce5c90f0bc36bb8f9260fc9cc@82.208.20.248:26656,9f4ea4b9da9801ba5e97924d13c7c793d94bfec9@45.147.199.176:26656,4fbe902fb542fc2cec818bc76b3857f2af251b52@84.46.242.68:26656,3db1eb8f5c41b8a551e3edd52e0d6150134d45f4@155.133.22.129:26656,03c587abea99f9494fd62ea017cddf1fda16338f@65.108.45.200:27262,867b72d6c8cbe690ae87eb32152cafa49484c6fd@65.109.32.174:27656,293cf1622c7f95e8654b99d1ba1fa784f11f5fd7@65.109.26.21:13656,7725b464de9314636d0e0124d046d4b63606ff09@5.161.99.35:26656,0f332b3b2e0013d3a52bcf0d85871e510628c90f@193.178.170.14:26656,b136caf667b9cb81de8c1858de300376d7a0ee0f@65.21.53.39:46656,69eb13f2e9865f58cd8b225fd1e8b6e6b8c7911a@45.147.199.199:26656,d99bc0d33e96fee388f6f5df5ee5b827a59c8560@57.128.144.242:26656"
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
