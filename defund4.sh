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
sudo apt install curl build-essential git wget jq make gcc tmux chrony lz4 unzip -y

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
git checkout v0.2.6
make build
sudo mv ./build/defundd /usr/local/bin/ || exit

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
PEERS="fd3353908a1e3eedb019451b2e55054bca2e5303@defund-testnet.nodejumper.io:28656,d45d007633b82518764ab12fafa543c46c848e5d@88.99.213.25:40656,03f469fb773c8a8c2a4cf4f4ba69ba7afb6895aa@86.48.2.194:26656,2a0d9a217a96dbe7f5bc9fccff8b50da29f41f52@5.9.147.185:18656,869173cd0f63a756010b6077e7e6cc03c56a1dcc@65.108.199.120:23156,7c459f88962a4d07d7ccd6d0c94f891bb7a7ada0@65.109.26.21:13656,c0098c96773cbd0d7507d037768845c582f1a878@65.108.202.230:27656,3e5d4205a82d9e5ed82ca8f4d0adb57522edb74e@65.108.72.233:06656,50d6b99caf4047c7110ba8db494bdfa0e7d3fa27@168.119.53.147:40656,73657fd476a5a21f74e2f9d61ddc24709035b9c2@65.108.209.237:40656,7d988c0b027cb08ccda631c5c4eb65e2a543f393@144.76.164.139:13656,cd3b0c2a3c5c7ae0f8f87a7d2346961698571219@65.108.14.216:27656,f1f81a8742132303519016ab73075cb5cc7f1bdf@5.161.65.211:26656,6415b5b1c9d141e0c177029918c7c7bf1ea02f50@5.75.157.68:26656,58437bc62307a512f391db5c1e24e3cff8b9f8d3@136.243.88.91:2070,a3ede88696b2b5f752129889b84b9292a168133a@142.132.152.46:21656,1abeab1952eeb684ea6323c540dde4d648c98fdb@167.235.148.138:26456,e332f554fab24feff380b906813a1d9759c6ceeb@167.235.10.164:13656,1d66e6a665d458219c2c3b83b51075154aed9055@65.109.171.194:26656,cfdf9097436fc79e4db5f4b1ae3c68e5a35fe52f@185.209.31.9:40656,6faad24350409a1b967b7a0315f609ff5b26da55@195.201.137.219:26656,9d6d8d2e4c5ed42a255c8fdc027ebbf8a01abeee@65.108.239.50:32656,7adc005534ee09c8b162bf9139663cbe1779ac69@65.108.206.118:36656,0883a65d7fd79a32f39320691dd5eab5b2c0810b@138.201.204.5:27656,fb124c136c3aa20a71c68d9cb0a2833293c8dc58@23.88.73.158:26656,93153d3b1e9178f44bbbddf809a8cf7177715c03@37.221.71.67:45656,bce98d5b268cb5164397c20235212fd704284772@79.137.207.21:26656,d39e6d823cace974d0836b1bd9df415f54efbaf4@95.216.227.146:27656,d16c05133b6cf47791c2442fa2452f5abaa2a12e@144.126.138.81:30656,2cfa496a4f5bd7e2bc28c45eb88d1b7319113393@162.19.171.42:20756,f3fd1d7363be7fa2e60324b0a9cd68b24bdecc3f@65.109.17.23:27656,d9975542e05f25e92ece8e8ca60f3f0b9af3315f@135.181.37.97:26656,41c877b907d5eae79b907ed7205b5cd363674133@65.108.78.101:26656,fa3b9aa4309d5e473040e71bca3fbd93f85bb842@65.108.110.23:40656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:40656,025e18cdef4248c889072deb4f7d4ccf35b1a999@65.21.124.230:26656,429c821a4a5aaa7f9e28aa7fe8d6fc7efc52d931@157.90.157.18:26656,2a04826aadf6bc60770e01e9548fc20798ce9132@65.109.94.250:26656,4281f6c569fc78c22cd53a21cad00099a853e4a0@173.249.11.244:26656,6b1d0569f71f28447574928adb7dd451656bc39f@144.91.99.234:30656,fe9d6f71a877116c5f09684cdb8946780b5d0051@65.108.42.97:26656,7ddf7769795b86bdf1da67e8fbd276f5bd3c843c@5.189.178.208:16656,b3348dd15eb99a2fbbfae923b9687c617670a13d@65.108.8.55:26656,4a7dc19c2a0790ee6d029a2ce08a96d1d552a3f1@65.108.226.49:26656,2a138efb5ef0638386af44c3df32ccdc8895b4d0@65.21.172.60:36656,46470acf5e7905fc877c6e25ccb606b00218c2fe@49.12.221.188:40656,126524e1a563d9e7082de4fea61aac69a724760f@188.34.182.100:40656,2601329aa3418e4a81377675545286b078cdd05c@5.75.144.35:26656,6fc3fab73a45c035a9e696bf55b7a7f994849814@135.181.208.169:35656,b0018ac03d48edb02a82bb92429cbe3fc75c58b1@161.97.172.129:26656,2850fc3e2a07f2f99a5fdd6d1d5bf2061e380f27@148.251.88.145:10556,3f47c8c01566cdec88442a7422c1372ea7877687@65.21.5.198:26656,519155b17def4a2c9b2c6f130ec62bee5c4e4e46@65.108.69.113:26656,9d62097edd303eefe1ea7b4a51a76e50d09cdada@185.16.39.13:26656,020abb71537ac87559814e1cb85cbd837046e836@23.88.5.169:23656,4e31497509557b7082a674185e0b45a243dcea80@142.132.202.86:17001,24a4ddf356553cdf544c977bcd424b2b4d5e99c6@135.181.26.181:40656,c07a59f54ded2f67054c10a7213e4d459e8510d7@65.109.84.215:46656,b41a924cf199ac04f5deeea164188b9ab9286aca@194.146.13.187:26656,cca29a905672845ce7744bc95532c77a41088e1c@194.146.13.189:26656,d489680927b14fc0382f637156375a351f59295b@95.111.237.228:30656,2a22241d6741288f431282ba7f26df802ff69c9e@78.47.52.150:40656,2796e8756692aad9886a21c870afb3a4894696cb@65.108.14.10:28656,1bb637816b9b28e428d515936d1d2cceb2d324cd@135.181.111.161:40656,abba990e6267d1d981ce1be52b69646e9bf4d1f6@65.21.134.250:13656,a617b2cc16502500dd16b1a726e313bf47deea7b@65.21.159.49:36656,622abc30449c900897c9257ee5a89b62fbc0a963@95.217.184.23:26656,c7380d0bd26c8915e99007432eab55a016ccf6f3@184.174.33.201:26656,e71cd965fb3ef91385ad9da7d24cbc039e23b2e4@157.90.150.144:26456,e3eec851aea32edd28a837e2f7a6562b3703eb0b@5.161.114.182:26656,0264e2223fc6e1aa917e3018521e1422532b1ecb@89.179.69.27:26656,51c8bb36bfd184bdd5a8ee67431a0298218de946@162.19.237.229:26656,9dd97305307c4c1a27bd82a91345155e052969c2@91.211.115.139:26656,89d66e9456d1648d7e49c2c105bad6037d5fdff9@65.108.60.71:26656,cfeffb77ac6e19fd70a65f6e7d6accd34e825f97@188.40.39.251:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@146.59.47.207:26836,b221ca8b1f87320016657fc1d741dd876262a786@213.239.207.175:26631,3b6198b6c0116463a005d00b114de6c38a27d976@5.78.90.103:40656,b1243df8b962f6dcdfe1e7b74e0e4bf9a287d2c5@164.68.109.229:26656,dd21f9f7d9559653f3713ab32893a025c1075d28@65.108.234.26:27656,1a8ff63090146d206ddf253e0bbbb35a6134079d@65.21.141.246:27656,26975c5bb7dc42463cc6361ea3c75f325e801917@85.10.197.4:40656,54315866e9a9c0bd7611a42a1caaf4a244316eb3@65.108.200.60:13656,a7a4fbf3ffe6c4f3910a27f27a4409d27c8d5a2d@20.230.17.170:26656,492f8fbaf5270cf739941979593757bea7bc8549@116.202.241.157:10156,e0fe1fd473a399b332280257e53f1fde933b3c5e@109.110.63.204:26656,7995a0be03d2909d90b2a7711fab1fb836475d5a@38.242.140.36:26656,d853aa171df502937dba6ab07025476e3fa5765d@194.163.151.27:26656,854cfaf6fd4de846fd020fbd7d0b5364c6fb9c58@65.21.95.46:27656,c659b2e0ec4027e6d4977c49917bdbd27451203f@130.185.119.129:26656,b12d0d19dc3ef0e701a76a0720443a7de3e1bbaa@213.226.100.159:26656,f05be2e85cb0cd1a5a5a6837b217d39c05dacf75@65.108.232.174:40656,5b3a2c084f0694b18fbfe560819cfbf3040ac24c@154.53.63.158:30656,0734eafb93fa465bf093a820be3480ee72e47520@195.2.85.100:40656,bba79e883e47c07cfee15e1eae803bd063a56ea8@65.108.41.83:26656,99598cb3cebb25a2f26f414be987ae1d397cdbe1@65.108.60.172:40656,6999cca6c55576a48d4f227b87dc904fbdb085aa@65.21.134.202:26576,b136caf667b9cb81de8c1858de300376d7a0ee0f@65.21.53.39:46656,133a675952763ee13b756a8c35729b7242c6958a@209.34.205.57:26656,b654f4b9394fcb6a98ca5845c70bb4026aa34fda@209.145.62.91:30656"
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
