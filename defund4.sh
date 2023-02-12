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
PEERS="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656,15d8ef2ae89c727dff1930e8e78894e6cd810774@95.217.134.242:40656,a9c4e48255c73cf49ea0459ef89c9c0a9ce9de80@65.108.240.79:26656,7831e762e13c2cb99236b59f5513bf1f8d16d036@88.99.3.158:10356,a3ede88696b2b5f752129889b84b9292a168133a@142.132.152.46:21656,aed2e345687433f661777c3692784368da47c9f5@65.108.237.231:30656,36909ce5289d8f994fb2562f7a188a79ce826359@141.95.145.41:27656,530d8e86f723deb9d544125540f23619a6710935@65.109.85.226:7030,1ef2946255fcfcd37d0f518ff9beab256223ecca@38.242.140.2:26656,52a7e50f858a85b10ddd52f9e01e060e0ec9c255@94.130.219.37:26656,955d9b23f6ddb8888ffd98602dcd579bf31a9bf7@212.90.120.42:40656,1080ee6a73afd9d516f08947493a37833d6c7d31@65.108.159.127:26656,b03f57e736985bc52fbdaef073908caf16e2ff6b@65.21.3.95:40656,75cccc67bc20e7e5429b80c4255ffe44ef24bc26@65.109.85.170:33656,e6b3dc37e08c1807cc044eb56061cfe0186af569@65.108.206.45:27656,475831e66548184ac8402e3dd3c9d39bd08b5c68@38.242.139.98:26656,cd5f808f4caebc851a00c56778d4f18c9c410883@161.97.83.175:26656,94abf10840eaebd1e2e576995a41fddbb6687497@185.219.142.198:26656,9544f5d727855f975c418e07adbbdebd66122b24@62.171.143.40:26656,f8093378e2e5e8fc313f9285e96e70a11e4b58d5@141.94.73.39:45656,2b76e96658f5e5a5130bc96d63f016073579b72d@51.91.215.40:45656,2e4e6c9545f95166f95b9d2d178dd77dd4afbbc6@5.75.247.54:26656,b86aa43bccc1d1000810d68fa0cf47c6c9f139ae@155.133.22.136:26656,9e67baeac323278617e9036a892464b21dfe3a38@65.108.71.92:45656,89865c3be8ed26d0ed4fd13d7bdec576beac20b6@65.108.150.197:40656,4df8eb475acb402f6c86b710bf1b7ac4fa7a87e9@194.146.13.254:26656,6fe5e0e9430ff243d122a3ffcff795c63cd370b2@109.123.251.149:26656,6ce9606ee3d1c98ead541355854a547befdaaabd@161.97.83.192:26656,9ef4a86e3981b53c8da75051a077489ad77cb4ba@5.75.138.108:26656,acad4439671fef4e64e904587a81ee9c34e9505d@95.216.214.103:40656,b86cc9aca68186e5c36d1fdea61b26860080b6ad@144.76.109.221:30656,293cf1622c7f95e8654b99d1ba1fa784f11f5fd7@65.109.26.21:13656,e6e7b14c4b241d27191e214fa9b187db5d44cf4f@65.109.70.23:11256,aa41f77ca39f4c7b609be90a8c89c52f1ccf53f7@95.216.114.212:40656,e9e00352288738317144af8bfeee3c2fb9b153de@65.108.54.91:26656,4598cef0683d229c628702180959721eba8c598b@142.132.253.112:18656,4d3b782ab389525370f53d40e970b1362bc92106@185.182.186.202:26656,ae33c58f2336e4d03a1501225bb85f901a06380a@65.108.101.42:26656,88a826840b0292af871c240dbdc6d368a475c7dc@65.108.108.52:13656,fd41b2da520e13fd87acd2fc914173795bef5935@161.97.78.178:26656,d1ba0f8137413cdce81ffaea04f8f25d1d5f32b6@65.109.167.55:26656,e2e1ebe485366ef5f7df0c9608f80da337dcc7db@167.235.203.235:26656,98f5af6f76dcbe21c7ce9d6b9e00ed4c56853dfe@65.109.137.238:26656,a9275c3b610215b4ce782b7563cb2f7e900567d5@65.108.80.143:26656,441a097ddce4ab3af08d58358c2a556e26abeec7@65.109.117.159:13656,eb85e9dd3bc977237258982bad5156da4f0eae1e@81.0.221.217:40656,6854d36513081c77a24987ab66a436e29e3e5cfa@65.21.131.215:26576,eea47be7c87a8af678e5884e5effaf7ec7abd651@91.200.42.23:26756,2fb53d2509f3bd47fa26f39d2a2c81347c9046ef@65.108.214.39:26656,f9785e004eedb616f9ca7749057f8394849a35ca@88.99.249.109:26656,cb38c94d1f547def1beb903757c9240e4775f6cc@162.55.1.2:33656,66de8f75e3d4a6b2c8e1e60df766d35bdb0c923d@194.61.28.32:40656,5692d0f133fe369e0c023a85455e731b517391ff@162.55.80.116:28656,70b50b469c5f1593fc9916c5ce94af99fc6948d4@209.34.206.40:26656,d1dfdfe42374e76021178b9735a48afcbb92d12b@46.21.151.114:48656,30823fe0963dbf4e4e563178cd834eb22bfbb3a2@65.108.232.238:13656,772eb457d152458c0c792a3afc38113203bdaa38@65.109.106.91:11656,c614192cb2b9a0efa91f4a380273996b047c39eb@5.199.136.57:26656,6139e22b12b345f0c470cef7abceed21321d1701@135.181.165.246:27656,fa94522ec824f2dc1a3a172400b6370667e7b546@158.247.232.165:40656,d99bc0d33e96fee388f6f5df5ee5b827a59c8560@57.128.144.242:26656,c022069023f6353103d93d273afb96c22efa9dc1@157.90.23.165:26656,5eadb035be45a8cb69491324805175b86dd11b6b@65.108.232.182:13656,f335bdc89890b6fa7acd75759a7aea42ea03a191@5.9.147.185:28656,38c2e79f4d9043aac5fd699d3bd5b8c3bdab0ab2@154.12.241.185:26656,6b02e5ff76245d9a815f0ad904112b3fd52b09d9@109.123.253.40:26656,566f0e430f75db2e9d6a13602d4f14bf61ed703f@109.123.254.250:26656,197b0b0bbada71fba5cc6e085c65dcd385b28847@65.21.192.90:13656,9defab88984fb8732e3bc33dd05cac99530c6509@89.163.255.100:26656,020abb71537ac87559814e1cb85cbd837046e836@23.88.5.169:23656,0d560c5dedc7415c45d9a9a6c8f4c4b69b0d31cc@65.108.8.55:26656,0c46cabe345df4df80981a18dfadc4855ae04de0@178.20.45.72:26656,6bcb7d5f9d0515f6e5d7f63b8ca5fb2df1fc9232@65.109.3.8:26656,ac951dced3334ce9f8cf8cbbe7ae12af7d6fd864@84.46.246.39:26656,51cd7e6e26ecc55785181a6b2d47645174fe025e@65.108.110.23:40656,634ef7bf5c9619a68414ee87cf530132703e5d7b@144.76.97.251:29656,05f77cfaf0c5a5e70c8f861decef07ef4f85462f@109.205.180.95:26656,773b4e59036c6934cdd3c919fc74259aba7d8ab3@185.16.39.4:26656,51bca4f513752941dd981c4cdde1378dc25aa712@23.88.66.239:33656,164e549bcddbfee83fe19810b645e80cac1b358d@65.109.12.79:26656,d2254b6e55c407f1bb3340ae78be94b89f644d14@185.215.167.45:26656,7c1a2a7239ee31e6bb0ba98e0d813a4a98feae59@5.161.65.211:26656,81346a65a3c1d6a515ebf898c0db90aee7faf3b9@65.108.233.220:13656,2529d1ca018f006cf47312936f550fdfa2ace0e7@95.70.238.194:40656,ef53af287e18b5a7af4b682bedb90abb6d0ca59a@144.76.164.139:13656,6999cca6c55576a48d4f227b87dc904fbdb085aa@65.21.134.202:26576,35cc34b214e52d98e8ab7c8f4b6aba0017c2347a@65.109.116.119:40656,da81aefc4d073f57d617c74c34a2fb2b68106dfa@37.157.255.110:26656,6bdaadd1f92186635b9c4418cac76b16021304b7@212.23.222.93:40656,4e27d91fdbe59af22aacc7d76d2b387ed899718d@176.124.221.177:40656,a56c51d7a130f33ffa2965a60bee938e7a60c01f@142.132.158.4:10656,cd3b0c2a3c5c7ae0f8f87a7d2346961698571219@65.108.14.216:27656,1e06daff380194a8bf49b2913d4d716b73a96e84@89.208.103.156:26656,8c2006b0c28ed9801cbdccdd63842afa24747681@195.2.74.112:40656,57520ca0b1354ec43ec524f51c1622277b000dd7@38.242.140.65:26656,d45d007633b82518764ab12fafa543c46c848e5d@88.99.213.25:40656,58437bc62307a512f391db5c1e24e3cff8b9f8d3@136.243.88.91:2070,4c6858fe14f0786ac6739b08a4b0782e458980cf@38.242.203.167:26656,968bb7ded4193e08587049d5a907512b9ea1f1f5@173.249.7.166:26656,1c4d96b6529211d2efcf4ea2e274eaff48da4ed0@65.109.70.4:40656"
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
