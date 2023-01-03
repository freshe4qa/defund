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
PEERS="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656,50631b5d915e4aa94b0dc8affe118e1840dca4e0@65.109.140.175:26656,0d190196414307625a087a2d3cd02756fb4643a7@65.108.13.185:26767,00ddc480c7373130e1086c54173ce2bc5e0e2d45@185.190.140.81:26656,ed118d21f2cb92a29d0c482b7a46d103c0ced625@185.202.223.162:26656,731a8728d4330530d23685ac3617af3734e1bf0e@62.141.32.185:26656,d7296c418c503d02356f2fe13ff3b3a4bf1bc70f@154.53.63.158:30656,b4c561813ad70b88ebcc12d7523b006573b2ca96@109.123.249.190:26656,0a1fcc2907e50b46f021389049c79f7d124f9946@77.51.200.79:36656,78f577049908ad58e3ea613855e55fbbd3f546de@207.180.233.65:30656,a297347e156af9fa8fe9e14fc3122e8fc44f61d2@185.217.127.150:26656,f9fd8aff0825e7c5fb76f7b6f42a4a2bbbdb04f7@84.46.244.224:26656,fd40c978275ceb1e0f9a81a7f40b3ec5f8b7b544@95.217.114.220:26656,d1d19e569b5dce459279e12d332bcd928abdf48b@65.109.37.58:14656,9c55522cc229ca89724d432f394374f1aa5269db@5.161.59.190:26656,ded2aa043bd924c1f36151ab749b59b5749037a3@65.21.203.204:26656,e03e9dfdf01e53b7db1e2eb4cbb2a993b7e3b705@194.4.49.63:26656,fa991418db3fcbccf6a0d94db313e52b758fbad2@95.216.14.72:32656,64a2be23e2f58e27c6797d26dd3c9f3ab5d9bc16@164.68.113.162:30656,06f809d76a0fd2653a9f4ecbd5bc9a92cb6d614d@192.9.134.157:26656,01b73409f0a44e9998af038259ce079af906c405@65.109.167.54:26656,e3c348467a8c88c0f65e2ca8a71875d2a384b8b4@185.16.39.19:60556,a9c4e48255c73cf49ea0459ef89c9c0a9ce9de80@65.108.240.79:26656,c1216ebc81a67e5b1685b1e85ab85eae169c4732@144.91.99.234:30656,d9315e4d36a0d36e5228143ce65bb01a7ae98ad0@62.113.117.179:26656,955d9b23f6ddb8888ffd98602dcd579bf31a9bf7@212.90.120.42:26656,a3ede88696b2b5f752129889b84b9292a168133a@142.132.152.46:21656,772eb457d152458c0c792a3afc38113203bdaa38@65.109.106.91:11656,6f6da87deb86be8d6fe273c557955c1324f1414c@86.48.5.82:26656,d2deca406ffd964a4681434ff50e9c5927f9f387@89.117.55.216:26656,8a650a9761db8abc1096abc3d4a68431600ae835@62.171.149.101:46656,514d7a0dc5c5ab4df2269e106f02554763a0cd69@88.210.9.169:26656,7b85da5bbdd0c88e7165ef4272e3edc68254f90e@154.12.231.14:26656,2d32413a875ef1f2a9b2f2c20758b547962971f7@194.163.162.153:40656,b914bb37cc8d1b7fb91579a79f7438a24d16de65@45.147.199.172:26656,381094ad4c3d77b53804101c38498dad30a63611@65.108.141.109:27656,f858783158275330cde90c3026c365dfcd84b254@65.21.132.27:28186,02642efcb81f1ae92442ae03985deb57fa3b717f@65.108.209.237:26656,b3ea7a581e2f1c1e19d2067e6cd54497914ec4ea@173.249.54.237:40656,ad9e3e6b195c3238463c030ed08db814465a1d9e@77.232.37.54:26656,9c158ab5f71de2896b2ba2f1203d09734c77235d@129.146.80.192:34656,7e936b2c89d1d1a757d262bc64f981ed48fb50ec@65.21.3.229:26656,e2ba8b6e24e3b2533d0ffbc1d1119dfd6b6ae49b@84.46.247.5:26656,0d3d09edc94fcc4401c9a592f7edaabd3d856214@217.76.62.73:26656,4d3b782ab389525370f53d40e970b1362bc92106@185.182.186.202:26656,9c3e02627a9b80a80266fcac6042feefe95bafd0@65.108.78.101:26656,4e489d7a3f0e34bd0ce1608e328c3a0aae36ddfc@154.53.55.91:30656,c1b574a8230bb51a6d1ae74071659ecdae1e968d@217.76.55.67:26656,0544670a43be0a61c7e354bc55d32b6573dc31cf@94.131.106.79:26656,8577f82b37e09c3e15e6852697107019b04c0679@217.76.55.70:26656,f0e1b5cbade7abe4a23fb12d0359c5bc40213718@95.217.109.222:26656,d7c675fa2eef507d4e2270c442383a886cade959@207.180.248.230:26656,43ec91e8ce243f0fd9686d34a353f3a62152ee2c@154.12.245.39:30656,733cfe295420fc7a7c03e137a807021b3b74c6ff@135.181.199.127:26656,fb73921dc5bf1e939308eaa37053c12bd647852b@45.147.199.210:26656,1218ac419c161e05707f4d7e95e7f754267506b4@65.109.17.23:56100,4e007e6957ba3f15f20da5bb8e0e9dea96a4b60c@89.109.44.172:26656,d1ba0f8137413cdce81ffaea04f8f25d1d5f32b6@65.109.167.55:26656,f022b6d6ed03d76a340c38da2001771eb7c7182c@144.126.149.19:30656,3d38bff6564e2738551725e34ec073c45b364c69@178.208.86.144:26656,5afcb5884900d343384c9fb717d3104ab28ee200@162.55.175.251:26656,81a3dbbf173184810cd734dd0ca9be39efc834d9@65.21.143.116:26656,56fc7b053b88c91e0ee17991ba42551952ae13f2@49.12.193.60:26656,a81536a4c272252f0b1e0b10c6d251768510f504@65.21.58.131:26656,8977990c6736e0cb9c88bb5d58c7c740e47dd113@95.70.184.178:44656,6c3445cfbfc182d61d502bfa8d6c74475af810d7@154.12.245.41:30656,2997819a47da2666714f1c0d675c0041d42682b1@94.103.91.239:26656,aee64a0d9b4f06f9f0949650fa22494b1cee1d58@84.46.244.228:26656,4eb0bef7997b87086c40766193d812479238187c@217.76.55.66:26656,81aac1c5a36ebe0ce9943b26d3d92e9a2856e928@144.126.157.206:30656,674f0368e8c7e1a8b9b0cd1a41e27dd05c2fa318@154.53.63.157:30656,1a2166e8c08130d678cae0bc88cfabc8b6ed8d78@178.18.244.17:26656,6b94a3f12d8e694c3a735078e0cfa2b27940012a@95.214.55.62:26656,26cf08ed9aa7fa3d940105ec773f08487b8d945a@45.85.147.42:36656,611fa8f9e30b531d12d517c2dd89eae132057c8b@217.76.55.69:26656,9dc6e421e815eb1f8374b07bd2bef4a5cbb9cb99@65.109.88.155:26656,a8f19ec6e056ddb81116c0614ef5f325d748f9be@109.123.247.177:26656,aa13a2feaa332ae60a49981c4445d0f92ee84e75@65.109.162.111:40656,06c6d28b6621aaf2e058d11c14aadab4d1742aec@217.76.49.193:26656,b6ed143531e3d3f5f2e2b767632129aff8e5649d@65.109.85.221:7030,fe1fe3318b450201b19827bbdf9d5aeb9ae2b916@207.180.236.115:31656,c675bd639c81562cb52e2b14bae0cbaaf78150bf@84.46.249.51:26656,e26b814071e94d27aa5b23a8548d69c45221fe28@135.181.16.252:26656,e2cfc10ce9b87e7571c8cbdd7c7335cfc087aea5@65.108.58.10:26656,c0bdcd0eff2c7c07a27a3a347077a4b2a0adf53b@192.248.144.252:26656,28d0f4d4b9debc4547e8d7862672171e7b2f8764@135.181.111.161:26656,fb5f99d34d60511d947ee077ef33005e438d0c0f@185.202.223.160:26656,20045ce5bdc8fbc356d82351305fe2f9f188a4b5@217.76.55.68:26656,d99bc0d33e96fee388f6f5df5ee5b827a59c8560@57.128.144.242:26656,68e1479b088c0258ca150b6beadd8bd7bd483059@176.120.177.123:26656,250f0a463898ed2ac434755af3abd24fb5176199@95.217.191.74:26656,07c5daee75c6395df8f14ba2b10d2374004cdea0@5.189.138.52:26656,a4c54654e473accc460d33016d8d334f068764b3@149.102.135.51:26656,a7cf78c4ec7bf69731c2cc9a5c1064e71e8e27d1@38.242.251.116:26656,ba0d5a6bc703e375067befcb601bf529805cec64@144.126.143.183:30656,2c4ddd8d4af5405618098648864d1d9975024aa3@95.216.173.157:26656,2b76e96658f5e5a5130bc96d63f016073579b72d@51.91.215.40:45656,3d367608bf7e481c77bd308237652d530edb921b@178.208.86.147:26656,219c417bd9de04c60f730abd4769e981f10c083b@109.123.249.191:26656,a629ef8303b7bb7b938c566c4d0c13d60653e83b@65.108.126.35:20656"
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

rm -rf $HOME/.defund/data 

SNAP_NAME=$(curl -s https://snapshots3-testnet.nodejumper.io/defund-testnet/ | egrep -o ">defund-private-3.*\.tar.lz4" | tr -d ">")
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
