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
PEERS="6366ac3af3995ecbc48c13ce9564aef0c7a6d7df@defund-testnet.nodejumper.io:28656,f03f3a18bae28f2099648b1c8b1eadf3323cf741@162.55.211.136:26656,a9c52398d4ea4b3303923e2933990f688c593bd8@157.90.208.222:36656,b136caf667b9cb81de8c1858de300376d7a0ee0f@65.21.53.39:46656,a56c51d7a130f33ffa2965a60bee938e7a60c01f@142.132.158.4:10656,5afcb5884900d343384c9fb717d3104ab28ee200@162.55.175.251:26656,01b73409f0a44e9998af038259ce079af906c405@65.109.167.54:26656,b2521331cc7ef94374208aae2c1ed8a3dcdd811b@95.217.118.100:28656,2b76e96658f5e5a5130bc96d63f016073579b72d@51.91.215.40:45656,f8093378e2e5e8fc313f9285e96e70a11e4b58d5@141.94.73.39:45656,28f14b89d10992cff60cbe98d4cd1cf84b1d2c60@88.99.214.188:26656,7831e762e13c2cb99236b59f5513bf1f8d16d036@88.99.3.158:10356,19142117150f4af5e32047dd27a6ac7ebb499eab@194.126.172.250:26656,86764a07a5cf35a3eb79981a65c9376675072a92@65.109.88.180:33656,b89b7a8f20d9f83c10caefaa883b4d173693b5b0@5.161.62.134:26656,a9c4e48255c73cf49ea0459ef89c9c0a9ce9de80@65.108.240.79:26656,a32570fc38ffbff20cd4cbf72b335f4ef810d017@65.21.105.44:26656,468d11101fd224836238b0bc2bec55356cd11a49@65.109.92.148:60556,c7617e0de4986c28be878833290197229b96b4f0@181.214.147.81:18656,2a138efb5ef0638386af44c3df32ccdc8895b4d0@65.21.172.60:36656,51cd7e6e26ecc55785181a6b2d47645174fe025e@65.108.110.23:40656,ef91b5e561f082b8659cc8e766bde80cfe02b853@161.97.111.248:40656,c1b574a8230bb51a6d1ae74071659ecdae1e968d@217.76.55.67:26656,55f17385f722c2f9e84850b1da5bb72de927d9c6@65.108.72.233:34656,a951a7d9e97baad1a3638578a0a98d2b76da1351@65.108.152.246:26656,836fccf97cd1e3d45c9e0ddd9c0a377a54f095ca@65.108.78.80:28656,1d28e2177c362fe2f032ba296c69142544d688f0@217.76.55.71:26656,fadb50dd153e127fbd56b7a4823beb355d4c103b@217.76.55.73:26656,3357d2ca92757c0dc13269690e5bbd55cd24355d@217.76.55.72:26656,0892f7c227b060ce398940b4a302c2228f98f7c7@109.123.247.238:26656,0c46cabe345df4df80981a18dfadc4855ae04de0@178.20.45.72:26656,e26b814071e94d27aa5b23a8548d69c45221fe28@135.181.16.252:26656,86813c773d619e716d35702a3f646f849869b920@5.75.142.37:26656,02642efcb81f1ae92442ae03985deb57fa3b717f@65.108.209.237:26656,36909ce5289d8f994fb2562f7a188a79ce826359@141.95.145.41:27656,f114c02efc5aa7ee3ee6733d806a1fae2fbfb66b@5.9.147.22:25656,6bcb7d5f9d0515f6e5d7f63b8ca5fb2df1fc9232@65.109.3.8:26656,7df04198931e556de89a8400a52e4fe8fc8bdfe3@65.108.60.172:26656,5b6efed49f2d1d51a29a2a1fe5d40a5417aa8578@95.216.100.241:40656,74e6425e7ec76e6eaef92643b6181c42d5b8a3b8@65.108.231.124:18656,a5293049c3cde07ed79d96f39a156a6c026056b4@65.108.4.233:26656,70ac77138022682d3cdd70a63428165bb3d22fc6@142.132.131.15:56656,3b91d9feed8ee4dbddf53e2ea6a1d628df32e09b@65.109.167.56:26656,d1ba0f8137413cdce81ffaea04f8f25d1d5f32b6@65.109.167.55:26656,e2cfc10ce9b87e7571c8cbdd7c7335cfc087aea5@65.108.58.10:26656,149363085e1ea7b9687b7a20dd8e4847d56ba22f@65.21.121.101:26656,915c68ce9dc6fd82c9e02422e8b3195c331605cb@94.130.137.122:27656,1a8ff63090146d206ddf253e0bbbb35a6134079d@65.21.141.246:27656,b221ca8b1f87320016657fc1d741dd876262a786@213.239.207.175:26631,00d5eeb0ac471c3f1a290160ed2116a0a9cefb7e@65.108.69.68:26858,b02d607514b5cf88f287f56f60ebeb084d216b5e@95.217.107.96:26656,ccd89e50733df2592ab4282dae2c266574fabe87@65.21.237.156:26656,5692d0f133fe369e0c023a85455e731b517391ff@162.55.80.116:28656,d45d007633b82518764ab12fafa543c46c848e5d@88.99.213.25:40656,cb503107b4135363d5ff83ff6a1a1423d8db4166@62.171.169.230:40656,07c5daee75c6395df8f14ba2b10d2374004cdea0@5.189.138.52:26656,a629ef8303b7bb7b938c566c4d0c13d60653e83b@65.108.126.35:20656,dca0e42d5d6838954ae08b5526c42a80c01d5538@159.69.74.237:26756,b6c474b89a8913f0907f816e5ac01886bc3f3896@154.26.128.99:36656,f858783158275330cde90c3026c365dfcd84b254@65.21.132.27:28186,47a8af17e27730f675f93bd94d80c2b282324ce8@95.216.42.83:28656,611fa8f9e30b531d12d517c2dd89eae132057c8b@217.76.55.69:26656,12029c7af734a0bd1628fc76070fb8f372ddb3c2@65.108.57.194:26656,da81aefc4d073f57d617c74c34a2fb2b68106dfa@37.157.255.110:26656,0d0309e38ed041c6038cb7f1e25f63d99cc046a8@142.132.166.157:25656,22e097c86358cb731fad2880291ed8e1f03b2012@65.108.78.101:26656,28b284b231c58c1751ef36b4354a70d065ef8c7e@95.217.207.236:28186,75cccc67bc20e7e5429b80c4255ffe44ef24bc26@65.109.85.170:33656,2c57fc71ccb618acd7823422afaa78bffb8550cd@65.109.93.152:31256,045202b03eff8179df3cea2282fbee8f4535836b@75.119.137.222:26656,6a49988aae3599f4eaf825212b1a475b571d682d@109.123.252.183:26656,71b1aceddd8b697c5e5ce22aee60ff1e1c5f20c5@176.124.222.160:26656,a53b8291bca2625fa1d71911dcab41f397c0559a@95.217.85.254:15613,e1294469301512646a6e7256f6094cba0f78cdb0@212.23.222.220:26856,772eb457d152458c0c792a3afc38113203bdaa38@65.109.106.91:11656,5a3e8478405460c847354dc3ab84437b51b2e50b@93.185.166.71:26656,17af52611a869d0161ee862ca0008f18e1573862@185.182.187.136:26656,aed2e345687433f661777c3692784368da47c9f5@65.108.237.231:30656,2796e8756692aad9886a21c870afb3a4894696cb@65.108.14.10:28656,0d4a295348a6ff61053606d749b77c0799f788fa@65.109.81.119:43656,1b575f8fee0338c09f6540d3748927754d9c97cb@213.239.216.252:42656,9c158ab5f71de2896b2ba2f1203d09734c77235d@129.146.80.192:34656,6bdaadd1f92186635b9c4418cac76b16021304b7@212.23.222.93:40656,4725abd8d2a813dce5c90f0bc36bb8f9260fc9cc@82.208.20.248:26656,ac0df3d4a9cc9378b5a2c905057f74e399eeea67@45.87.104.39:26656,3d367608bf7e481c77bd308237652d530edb921b@178.208.86.147:26656,7725b464de9314636d0e0124d046d4b63606ff09@5.161.99.35:26656,0d61434e2b695693624c6f3416ab8024f57ccef4@89.163.219.202:26656,a8f19ec6e056ddb81116c0614ef5f325d748f9be@154.12.251.27:26656,e6b3dc37e08c1807cc044eb56061cfe0186af569@65.108.206.45:27656,7e936b2c89d1d1a757d262bc64f981ed48fb50ec@65.21.3.229:26656,00ddc480c7373130e1086c54173ce2bc5e0e2d45@185.190.140.81:26656,2176867f2c9349335d1083e85801b49767217866@162.55.242.150:29656,ff2a60947456e47f259252ee874302279cf897f9@178.63.8.245:46656,c0098c96773cbd0d7507d037768845c582f1a878@65.108.202.230:27656,e0fe1fd473a399b332280257e53f1fde933b3c5e@109.110.63.204:26656,8577f82b37e09c3e15e6852697107019b04c0679@217.76.55.70:26656,997da62262006ce89d5019b7820b5552118e0df2@138.201.17.11:28656,eae5ac955ae728834c1cf85b7f1eea9ccaa1b41c@38.242.239.193:26656,03c587abea99f9494fd62ea017cddf1fda16338f@65.108.45.200:27262"
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
