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
PEERS="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656,15d8ef2ae89c727dff1930e8e78894e6cd810774@95.217.134.242:40656,a56c51d7a130f33ffa2965a60bee938e7a60c01f@142.132.158.4:10656,7831e762e13c2cb99236b59f5513bf1f8d16d036@88.99.3.158:10356,a3ede88696b2b5f752129889b84b9292a168133a@142.132.152.46:21656,aed2e345687433f661777c3692784368da47c9f5@65.108.237.231:30656,36909ce5289d8f994fb2562f7a188a79ce826359@141.95.145.41:27656,2529d1ca018f006cf47312936f550fdfa2ace0e7@95.70.238.194:40656,12cae75d49d0bc7596b99aba3235b0160c6e2189@65.108.98.41:40656,bf05df3550272f56495e9d4cf2637dd6554e36a6@38.242.139.242:26656,4598cef0683d229c628702180959721eba8c598b@142.132.253.112:18656,1b575f8fee0338c09f6540d3748927754d9c97cb@213.239.216.252:42656,b03f57e736985bc52fbdaef073908caf16e2ff6b@65.21.3.95:40656,75cccc67bc20e7e5429b80c4255ffe44ef24bc26@65.109.85.170:33656,e6b3dc37e08c1807cc044eb56061cfe0186af569@65.108.206.45:27656,5aa4811cd346737c2d8978a6ec8df9491c5091ad@116.202.241.157:35656,cd5f808f4caebc851a00c56778d4f18c9c410883@161.97.83.175:26656,94abf10840eaebd1e2e576995a41fddbb6687497@185.219.142.198:26656,24b9e55f163da4941c455a18f4d37d6ce4e3f901@94.103.91.211:40656,f8093378e2e5e8fc313f9285e96e70a11e4b58d5@141.94.73.39:45656,f91badf2813964b3b0dc7e05378253aa22bfb7b4@65.109.88.254:27656,88a826840b0292af871c240dbdc6d368a475c7dc@65.108.108.52:13656,b86aa43bccc1d1000810d68fa0cf47c6c9f139ae@155.133.22.136:26656,9e67baeac323278617e9036a892464b21dfe3a38@65.108.71.92:45656,da81aefc4d073f57d617c74c34a2fb2b68106dfa@37.157.255.110:26656,4df8eb475acb402f6c86b710bf1b7ac4fa7a87e9@194.146.13.254:26656,6fe5e0e9430ff243d122a3ffcff795c63cd370b2@109.123.251.149:26656,e0ab16d47276dee411fc01abc86c787d95ef6aba@65.109.111.204:29656,e0fe1fd473a399b332280257e53f1fde933b3c5e@109.110.63.204:26656,4c9216ad46e34e8134751c5d389220e99e651300@194.146.13.252:26656,b86cc9aca68186e5c36d1fdea61b26860080b6ad@144.76.109.221:30656,bfa961affeae830e8f141e721ca4845d002b1fa5@65.108.42.97:26656,308c45343132c8cf9e086ae53306ef2a6aeb4998@95.217.106.209:40656,f2bb49aff5b6748557410d3a2f7bbd9305cd9dc6@65.109.84.215:36656,731a8728d4330530d23685ac3617af3734e1bf0e@62.141.32.185:26656,4d0d6cd222ba18f9f840355700d39e04dc4f4e8e@161.97.78.40:26656,b8041e161aaa79715f76c85f3fe3011559223494@89.163.142.196:26656,e26206d0e39515fb07915b28e468729340eb112e@38.242.244.163:26656,2e4e6c9545f95166f95b9d2d178dd77dd4afbbc6@5.75.247.54:26656,2b76e96658f5e5a5130bc96d63f016073579b72d@51.91.215.40:45656,228caaf18704dac5c423f8a19e12a0d66c10d012@161.97.81.155:26656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:40656,b2d33977b8bca9790df391dd3559e65514f95c0f@194.146.13.253:26656,9b46be54807367fe2c16acfff652a69e8d3ce764@86.48.24.29:26656,441a097ddce4ab3af08d58358c2a556e26abeec7@65.109.117.159:13656,2a0d9a217a96dbe7f5bc9fccff8b50da29f41f52@5.9.147.185:18656,d089beab9fcccd6b95217f0972831d6d861a9009@164.68.109.229:26656,4d3b782ab389525370f53d40e970b1362bc92106@185.182.186.202:26656,d7c675fa2eef507d4e2270c442383a886cade959@207.180.248.230:26656,75a611e4037ad21736ebb6d499dd37f366fe5c24@65.108.41.168:26656,6049243e8e22d615cfeff0d4e14f7fb4a0c8465e@155.133.22.19:26656,66de8f75e3d4a6b2c8e1e60df766d35bdb0c923d@194.61.28.32:40656,5692d0f133fe369e0c023a85455e731b517391ff@162.55.80.116:28656,70b50b469c5f1593fc9916c5ce94af99fc6948d4@209.34.206.40:26656,f9fcb1705d112b357fa498bb0711e2f4953d3f88@85.10.202.135:40656,30823fe0963dbf4e4e563178cd834eb22bfbb3a2@65.108.232.238:13656,772eb457d152458c0c792a3afc38113203bdaa38@65.109.106.91:11656,c614192cb2b9a0efa91f4a380273996b047c39eb@5.199.136.57:26656,51bca4f513752941dd981c4cdde1378dc25aa712@23.88.66.239:33656,543480a7a6fef2555f540039e487543b90a3a7ca@95.214.53.187:16656,00b7377492dfcfaf9a3ac61d9fe521e0b8fd08dd@65.109.113.247:13656,f9785e004eedb616f9ca7749057f8394849a35ca@88.99.249.109:26656,5eadb035be45a8cb69491324805175b86dd11b6b@65.108.232.182:13656,678c9f30f06c99fb3ed5023b4b3f55de063bc2b1@217.76.62.73:26656,55f17385f722c2f9e84850b1da5bb72de927d9c6@65.108.72.233:34656,6b02e5ff76245d9a815f0ad904112b3fd52b09d9@109.123.253.40:26656,38c2e79f4d9043aac5fd699d3bd5b8c3bdab0ab2@154.12.241.185:26656,197b0b0bbada71fba5cc6e085c65dcd385b28847@65.21.192.90:13656,0892f7c227b060ce398940b4a302c2228f98f7c7@109.123.247.238:26656,672d909da12220d28d4c63e45c66b764c2d0b5f4@84.46.242.63:26656,0d560c5dedc7415c45d9a9a6c8f4c4b69b0d31cc@65.108.8.55:26656,0c46cabe345df4df80981a18dfadc4855ae04de0@178.20.45.72:26656,6bcb7d5f9d0515f6e5d7f63b8ca5fb2df1fc9232@65.109.3.8:26656,ac951dced3334ce9f8cf8cbbe7ae12af7d6fd864@84.46.246.39:26656,51cd7e6e26ecc55785181a6b2d47645174fe025e@65.108.110.23:40656,3d57a684fb53f41fb755af5c64d62433b80b1bbd@167.235.206.216:26656,06739b3c47ad6fd22426104ac9077d2314459ee5@89.117.56.126:24156,feaf23d0c4e2726e823cbd275acbef74df8333cf@165.22.218.21:26656,13e5fb91e66d4ff918f466c20e5b82b58396a88a@5.9.122.49:13656,720d9aae9e4dcbf09adb3b463e21c2d447991563@89.117.58.38:26656,e2e1ebe485366ef5f7df0c9608f80da337dcc7db@167.235.203.235:26656,2218acbe81b1f57da84cf0db5ebb6fe65e5e3362@65.21.205.248:18656,81346a65a3c1d6a515ebf898c0db90aee7faf3b9@65.108.233.220:13656,149363085e1ea7b9687b7a20dd8e4847d56ba22f@65.21.121.101:26656,860ad5d22a572f9858d38d13c72808c18edba781@213.226.100.159:26656,6999cca6c55576a48d4f227b87dc904fbdb085aa@65.21.134.202:26576,78a6d1c13ba66885a4393c72f7535cb42c9d3e8e@194.126.173.150:31656,52a7e50f858a85b10ddd52f9e01e060e0ec9c255@94.130.219.37:26656,a5603aff95643b7705d08b7a48e73a1366499e27@135.181.59.182:22656,377da550df4ee1643d9e3f23f7c9827b38688f2b@194.146.13.185:26656,d1ba0f8137413cdce81ffaea04f8f25d1d5f32b6@65.109.167.55:26656,cd3b0c2a3c5c7ae0f8f87a7d2346961698571219@65.108.14.216:27656,e374c0d40d3fd948e91e239fe67c9d7a8fff4995@65.108.101.124:13656,1e06daff380194a8bf49b2913d4d716b73a96e84@89.208.103.156:26656,57520ca0b1354ec43ec524f51c1622277b000dd7@38.242.140.65:26656,eb4ff043efb72e4f8f320933e6f4f68a9d5e09a7@65.21.237.241:26656,7d985c13f04fd3086875da81393d047cb07b8c0e@154.53.34.180:26656,4c6858fe14f0786ac6739b08a4b0782e458980cf@38.242.203.167:26656,e9907cacf2bbe056661cf539806d8945c5320e1b@155.133.23.25:26656,e199e4d17120559bc34357d72f6595cbcd4d5cd4@173.212.216.232:26656"
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

curl https://snapshots-testnet.nodejumper.io/defund-testnet/defund-private-4_2023-02-06.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.defund

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
