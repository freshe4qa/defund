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
curl -s https://raw.githubusercontent.com/defund-labs/testnet/main/defund-private-4/genesis.json > ~/.defund/config/genesis.json
curl -s https://snapshots2-testnet.nodejumper.io/defund-testnet/addrbook.json > $HOME/.defund/config/addrbook.json

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
PEERS="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656,1ef2946255fcfcd37d0f518ff9beab256223ecca@38.242.140.2:26656,e26206d0e39515fb07915b28e468729340eb112e@38.242.244.163:26656,1c4d96b6529211d2efcf4ea2e274eaff48da4ed0@65.109.70.4:40656,293cf1622c7f95e8654b99d1ba1fa784f11f5fd7@65.109.26.21:13656,e374c0d40d3fd948e91e239fe67c9d7a8fff4995@65.108.101.124:13656,36909ce5289d8f994fb2562f7a188a79ce826359@141.95.145.41:27656,6ce9606ee3d1c98ead541355854a547befdaaabd@161.97.83.192:26656,ccc69309c5b72f7731b910920167c31143bf4e44@155.133.22.127:26656,f3320f440031319e0985b6781c89b755e2a823de@141.95.82.222:40656,a3ede88696b2b5f752129889b84b9292a168133a@142.132.152.46:21656,5aa4811cd346737c2d8978a6ec8df9491c5091ad@116.202.241.157:35656,e0c818b261522c42c1a3283cdbaacbe6ee262747@95.217.130.95:26656,2688f7a8c66d0bcb215380d2fe06a1c16fb9be91@161.97.151.1:26656,5a3e8478405460c847354dc3ab84437b51b2e50b@93.185.166.71:26656,55f17385f722c2f9e84850b1da5bb72de927d9c6@65.108.72.233:34656,d9f1a0f399c8db62206edb2be29a313829fc8521@135.181.128.19:26656,377da550df4ee1643d9e3f23f7c9827b38688f2b@194.146.13.185:26656,7e41dbba7a063622e271cf217ad94b342157f796@185.209.230.89:26656,9d98188f51c4efd4bc04c09d985a4c490d12ebde@65.109.117.165:40656,024cd4c3e82707ca457c651dbbb0aab95cdde224@88.208.57.200:40656,ac951dced3334ce9f8cf8cbbe7ae12af7d6fd864@84.46.246.39:26656,2b76e96658f5e5a5130bc96d63f016073579b72d@51.91.215.40:45656,2796e8756692aad9886a21c870afb3a4894696cb@65.108.14.10:28656,aa41f77ca39f4c7b609be90a8c89c52f1ccf53f7@95.216.114.212:26656,15d8ef2ae89c727dff1930e8e78894e6cd810774@95.217.134.242:40656,b221ca8b1f87320016657fc1d741dd876262a786@213.239.207.175:26631,9fa8d48c2882c17f856602ad16ec141b57853a62@38.242.139.96:26656,475831e66548184ac8402e3dd3c9d39bd08b5c68@38.242.139.98:26656,71118d693ca0e03bf32fe6ef6fbba72710bedf7e@155.133.22.135:26656,5692d0f133fe369e0c023a85455e731b517391ff@162.55.80.116:28656,24b9e55f163da4941c455a18f4d37d6ce4e3f901@94.103.91.211:40656,0e191c0d1fed5e6745bee750309a9730beacd667@178.239.197.171:26656,8c2006b0c28ed9801cbdccdd63842afa24747681@195.2.74.112:40656,f8093378e2e5e8fc313f9285e96e70a11e4b58d5@141.94.73.39:45656,8abfa09fdbea667157d96f79c815fd9b3186b6ae@65.109.92.240:2026,2a138efb5ef0638386af44c3df32ccdc8895b4d0@65.21.172.60:36656,4d0d6cd222ba18f9f840355700d39e04dc4f4e8e@161.97.78.40:26656,278602404e78c23f5aff7a04802179ad7ffaa676@18.234.102.132:26656,72707c0152742ffdb2aa9f154799f476817c8cce@45.14.194.173:26656,f114c02efc5aa7ee3ee6733d806a1fae2fbfb66b@5.9.147.22:25656,146c39262878fdba5898753c5dc2272d4800e971@142.132.208.26:26856,0d560c5dedc7415c45d9a9a6c8f4c4b69b0d31cc@65.108.8.55:26656,38c2e79f4d9043aac5fd699d3bd5b8c3bdab0ab2@154.12.241.185:26656,1218ac419c161e05707f4d7e95e7f754267506b4@65.109.17.23:56214,cf5c4fedd75b2cd0db38a51389cd39d01135bd82@135.125.190.227:40656,5ba975533e25b25e84df48bc6aeeed108f78aba4@209.126.2.211:26656,197b0b0bbada71fba5cc6e085c65dcd385b28847@65.21.192.90:13656,149363085e1ea7b9687b7a20dd8e4847d56ba22f@65.21.121.101:26656,5beca302247bb83bac77c18ac86ed01ec4d65f62@155.133.23.29:26656,672d909da12220d28d4c63e45c66b764c2d0b5f4@84.46.242.63:26656,b92fd75abcb2791ca087102448f2ca3860471ee7@65.108.200.60:13656,de2574d069145e6d6ca35774964ccc919497f428@84.46.250.215:40656,21da57ac0818a8a34f4d108b5f6c2580b994f7d7@38.242.239.27:36656,9f8c039d3694a00360d4464f4471257d4b01e7cd@65.109.90.162:26656,024981c993824fb347e3b007cbbabec211925bf1@144.91.89.149:30656,a5293049c3cde07ed79d96f39a156a6c026056b4@65.108.4.233:26656,9ef4a86e3981b53c8da75051a077489ad77cb4ba@5.75.138.108:26656,89865c3be8ed26d0ed4fd13d7bdec576beac20b6@65.108.150.197:40656,4651011654725b77f897a8c92e4324384c95ce84@38.242.244.176:26656,6632ecd0dc1ca51ae858c6f08c46f2fdc959c433@155.133.23.28:26656,cafb29a21cf94b3bdbc9149344b092fa40ea22f4@65.109.63.110:13656,30823fe0963dbf4e4e563178cd834eb22bfbb3a2@65.108.232.238:13656,88a826840b0292af871c240dbdc6d368a475c7dc@65.108.108.52:13656,6999cca6c55576a48d4f227b87dc904fbdb085aa@65.21.134.202:26576,edbc922818a4ecbf13faac82c8719d479c449d28@5.199.136.57:26656,a79130668102f116a23cfcf9fd94623de4a223fe@81.30.157.35:10656,3393cfd5d08561f019b2cd6ce076c3e63102baf6@65.108.105.48:11256,19142117150f4af5e32047dd27a6ac7ebb499eab@194.126.172.250:26656,b4f12c703c29169b4c58345751ba093d7850d517@65.109.89.58:28656,772eb457d152458c0c792a3afc38113203bdaa38@65.109.106.91:11656,5b6efed49f2d1d51a29a2a1fe5d40a5417aa8578@95.216.100.241:40656,3906282a3e2b40fb81ef887d43fc8acabfd5f54b@65.109.117.229:35656,a640c8725c97ef4491037c0494442ed8e3fd7024@194.146.13.189:26656,f01079014db8293225f708e44725f64a25495145@65.21.187.135:26656,5afcb5884900d343384c9fb717d3104ab28ee200@162.55.175.251:26656,aee64a0d9b4f06f9f0949650fa22494b1cee1d58@84.46.244.228:26656,7d985c13f04fd3086875da81393d047cb07b8c0e@154.53.34.180:26656,95778d4f8da28dcec38be627c0a6b8e513f91f30@155.133.22.130:26656,1080ee6a73afd9d516f08947493a37833d6c7d31@65.108.159.127:26656,d1ba0f8137413cdce81ffaea04f8f25d1d5f32b6@65.109.167.55:26656,3db1eb8f5c41b8a551e3edd52e0d6150134d45f4@155.133.22.129:26656,69cce9d9a6f24c1cdada09bc7afed34937d39dea@89.163.209.173:40656,41da85e7d2508400bc5a6d3843a1b0e258243985@155.133.22.128:26656,6f82e772ee8ae1895edc9743dbb269fb7c33f06a@144.91.89.158:30656,12d2829187ba3627c44944c1ee99218da4328e16@178.63.8.245:60956,d1649b67ea85b597064198f287414b9e3a93fa41@154.53.32.169:30656,a5603aff95643b7705d08b7a48e73a1366499e27@135.181.59.182:22656,3a8911a5dc4d53f2eb4174b60f2d6403529cd467@162.55.46.131:36656,dd21f9f7d9559653f3713ab32893a025c1075d28@65.108.234.26:27656,228caaf18704dac5c423f8a19e12a0d66c10d012@161.97.81.155:26656,a9fb2882e8178313adc80eb34cf172beb2b7cdf6@217.79.187.22:26656,58437bc62307a512f391db5c1e24e3cff8b9f8d3@136.243.88.91:2070,acad4439671fef4e64e904587a81ee9c34e9505d@95.216.214.103:40656"
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

curl https://snapshots2-testnet.nodejumper.io/defund-testnet/defund-private-4_2023-03-04.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.defund

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
