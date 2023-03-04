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
PEERS="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656,475831e66548184ac8402e3dd3c9d39bd08b5c68@38.242.139.98:26656,dd21f9f7d9559653f3713ab32893a025c1075d28@65.108.234.26:27656,71118d693ca0e03bf32fe6ef6fbba72710bedf7e@155.133.22.135:26656,e3ddb054a619da2205b72b6de5aefbce2b451a0f@81.0.247.136:26656,b92fd75abcb2791ca087102448f2ca3860471ee7@65.108.200.60:13656,7c1a2a7239ee31e6bb0ba98e0d813a4a98feae59@5.161.65.211:26656,36909ce5289d8f994fb2562f7a188a79ce826359@141.95.145.41:27656,3db1eb8f5c41b8a551e3edd52e0d6150134d45f4@155.133.22.129:26656,024cd4c3e82707ca457c651dbbb0aab95cdde224@88.208.57.200:40656,968bb7ded4193e08587049d5a907512b9ea1f1f5@173.249.7.166:26656,89865c3be8ed26d0ed4fd13d7bdec576beac20b6@65.108.150.197:40656,e374c0d40d3fd948e91e239fe67c9d7a8fff4995@65.108.101.124:13656,e21aa9dfe1a522453bb89a290cf49a476cf38bea@65.21.58.9:40656,75a611e4037ad21736ebb6d499dd37f366fe5c24@65.108.41.168:26656,72707c0152742ffdb2aa9f154799f476817c8cce@45.14.194.173:26656,634ef7bf5c9619a68414ee87cf530132703e5d7b@144.76.97.251:29656,e2cfc10ce9b87e7571c8cbdd7c7335cfc087aea5@65.108.58.10:26656,9caa4ac64062fa1178a9db93d24209841bbd30ba@199.175.98.110:26656,0e191c0d1fed5e6745bee750309a9730beacd667@178.239.197.171:26656,74ccc887fb6ff86b6873c2f9a27ecf56e7a2e976@38.242.139.95:26656,5b6efed49f2d1d51a29a2a1fe5d40a5417aa8578@95.216.100.241:40656,f676706d734970eac84033d31e836bf2142ef5a4@65.108.9.164:38656,6999cca6c55576a48d4f227b87dc904fbdb085aa@65.21.134.202:26576,692610e4e05fb6e7863c6510d47e849ccf4ee8af@155.133.22.126:26656,772eb457d152458c0c792a3afc38113203bdaa38@65.109.106.91:11656,7831e762e13c2cb99236b59f5513bf1f8d16d036@88.99.3.158:10356,41da85e7d2508400bc5a6d3843a1b0e258243985@155.133.22.128:26656,ac951dced3334ce9f8cf8cbbe7ae12af7d6fd864@84.46.246.39:26656,55f17385f722c2f9e84850b1da5bb72de927d9c6@65.108.72.233:34656,7e41dbba7a063622e271cf217ad94b342157f796@185.209.230.89:26656,4cba19ddef88584c8304794e0bb9960c47c43e05@65.109.25.58:13656,149363085e1ea7b9687b7a20dd8e4847d56ba22f@65.21.121.101:26656,293cf1622c7f95e8654b99d1ba1fa784f11f5fd7@65.109.26.21:13656,1218ac419c161e05707f4d7e95e7f754267506b4@65.109.17.23:56214,5ba975533e25b25e84df48bc6aeeed108f78aba4@209.126.2.211:26656,12339866b54981ecf4f9f737535d44a9fcd8033e@159.69.152.235:26656,bfa961affeae830e8f141e721ca4845d002b1fa5@65.108.42.97:26656,58437bc62307a512f391db5c1e24e3cff8b9f8d3@136.243.88.91:2070,2a0d9a217a96dbe7f5bc9fccff8b50da29f41f52@5.9.147.185:18656,ccc69309c5b72f7731b910920167c31143bf4e44@155.133.22.127:26656,bf79c86bb825ea377d1493c8d59b92cb37ed29b7@65.109.121.112:36656,0d560c5dedc7415c45d9a9a6c8f4c4b69b0d31cc@65.108.8.55:26656,2b76e96658f5e5a5130bc96d63f016073579b72d@51.91.215.40:45656,146c39262878fdba5898753c5dc2272d4800e971@142.132.208.26:26856,a640c8725c97ef4491037c0494442ed8e3fd7024@194.146.13.189:26656,5692d0f133fe369e0c023a85455e731b517391ff@162.55.80.116:28656,9f8c039d3694a00360d4464f4471257d4b01e7cd@65.109.90.162:26656,cf5c4fedd75b2cd0db38a51389cd39d01135bd82@135.125.190.227:40656,f3320f440031319e0985b6781c89b755e2a823de@141.95.82.222:40656,5aa4811cd346737c2d8978a6ec8df9491c5091ad@116.202.241.157:35656,d1ba0f8137413cdce81ffaea04f8f25d1d5f32b6@65.109.167.55:26656,15d8ef2ae89c727dff1930e8e78894e6cd810774@95.217.134.242:40656,e0c818b261522c42c1a3283cdbaacbe6ee262747@95.217.130.95:26656,4d3b782ab389525370f53d40e970b1362bc92106@185.182.186.202:26656,a3ede88696b2b5f752129889b84b9292a168133a@142.132.152.46:21656,aed2e345687433f661777c3692784368da47c9f5@65.108.237.231:30656,8bc1cf85265a770ffdd0193c7ca153659046feab@95.217.214.124:40656,5beca302247bb83bac77c18ac86ed01ec4d65f62@155.133.23.29:26656,2796e8756692aad9886a21c870afb3a4894696cb@65.108.14.10:28656,eb4ff043efb72e4f8f320933e6f4f68a9d5e09a7@65.21.237.241:26656,1ef2946255fcfcd37d0f518ff9beab256223ecca@38.242.140.2:26656,672d909da12220d28d4c63e45c66b764c2d0b5f4@84.46.242.63:26656,5afcb5884900d343384c9fb717d3104ab28ee200@162.55.175.251:26656,01b73409f0a44e9998af038259ce079af906c405@65.109.167.54:26656,76d932d75b5de4c1799f8702b0047a4ab3de1b14@154.53.63.156:26656,e2558f39b4b18b2dc9425221383877d09e2fbeb7@209.126.1.248:26656,6ce9606ee3d1c98ead541355854a547befdaaabd@161.97.83.192:26656,e66e19289f671e734bee82f79e5e8ca5da7d249b@155.133.27.251:27656,30823fe0963dbf4e4e563178cd834eb22bfbb3a2@65.108.232.238:13656,4a845b22163fca1b8445fa3988628ac694e3f30e@89.163.133.136:40656,51cd7e6e26ecc55785181a6b2d47645174fe025e@65.108.110.23:40656,020abb71537ac87559814e1cb85cbd837046e836@23.88.5.169:23656,1c4d96b6529211d2efcf4ea2e274eaff48da4ed0@65.109.70.4:40656,7d985c13f04fd3086875da81393d047cb07b8c0e@154.53.34.180:26656,b4f12c703c29169b4c58345751ba093d7850d517@65.109.89.58:28656,b86aa43bccc1d1000810d68fa0cf47c6c9f139ae@155.133.22.136:26656,2688f7a8c66d0bcb215380d2fe06a1c16fb9be91@161.97.151.1:26656,88a826840b0292af871c240dbdc6d368a475c7dc@65.108.108.52:13656,b221ca8b1f87320016657fc1d741dd876262a786@213.239.207.175:26631,41c5b53745e065bee2f46970e6590ce1c4884401@164.68.113.190:26656,9fa8d48c2882c17f856602ad16ec141b57853a62@38.242.139.96:26656,e26206d0e39515fb07915b28e468729340eb112e@38.242.244.163:26656,da81aefc4d073f57d617c74c34a2fb2b68106dfa@37.157.255.110:26656,38c2e79f4d9043aac5fd699d3bd5b8c3bdab0ab2@154.12.241.185:26656,aa5597ed868112e494c058fd7ca4b05932074559@164.68.103.176:26656,0c5f81fc174f73931a118a38186e4216ed665655@84.46.249.44:26656,b2d33977b8bca9790df391dd3559e65514f95c0f@194.146.13.253:26656,377da550df4ee1643d9e3f23f7c9827b38688f2b@194.146.13.185:26656,bb976ad340709857feae4daa3f4f95a7cf4e5ade@85.239.233.104:26656,a79130668102f116a23cfcf9fd94623de4a223fe@81.30.157.35:10656,2d23c2cc0bab50f7c27663ab83afd1556e009133@155.133.22.137:26656,11dd3e4614218bf584b6134148e2f8afae607d93@142.132.231.118:26656,f393c1e540566d94ee840ef64431136b1d35d3a6@5.189.159.198:28656"
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
