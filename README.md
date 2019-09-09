# PegNet Mining Tutorial

PegNet Compose leverages Docker Compose to help you start and manage a PegNet miner.

## Requirements

-   Linux (Debian / Ubuntu preferred)
-   Windows

## Setup

This is the initial setup process. You will only need to do this once.

#### 1. Clone and cd into this repo

```shell script
git clone https://github.com/pegnet/pegnet-compose.git && cd pegnet-compose
```

#### 2. Install Docker and Docker-Compose (skip this if already installed)

##### Linux:
- run `sudo ./get_started.sh` (easiest way)

or

- copy and run the following commands:
```shell script
sudo apt-get update && sudo apt-get install curl python3 apt-transport-https ca-certificates software-properties-common -y && curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh && sudo usermod -aG docker pi && sudo pip3 install docker-compose
```


After installing Docker it's better to reboot the machine

##### Windows:
- Install Docker and Docker Compose (https://docs.docker.com/docker-for-windows/install/)


#### 3. Get the bootstrap file (skip this if you want to sync the blockchain from scratch)

##### Linux:
- run `cd volumes/factomd; sudo ./bootstrap.sh`

##### Windows:
- download [this file](https://factom-public-files.s3.us-east-2.amazonaws.com/bootstrap.zip) and unzip it into `volumes/factomd/main-database/ldb/MAIN/`


#### 4. Config files
The default file `config/factomd.conf` should work for most people, however feel free to edit it to fit your needs.


#### 5. Start `factomd`

Start `factomd` to finish syncing the blockchain

```shell script
docker-compose up -d factomd
```

#### 6. Check sync progress

`factomd` will launch a cool control panel where you can check the progress of the sync: http://localhost:8090

This might take a couple of hours if you used the bootstrap file, otherwise it might take over a day.

You can also track it at the command line with the following command.

```shell script
docker-compose exec factomd curl -X POST --data-binary '{"jsonrpc": "2.0", "id": 0, "method": "heights"}' -H 'content-type:text/plain;' http://localhost:8088/v2
```

It has finished syncing when all the heights are the same.

#### 7. After the sync is done, start `walletd`

`docker-compose up -d walletd`

#### 8. Create or add an entry credit address

##### a. Create an entry credit address

```shell script
docker-compose exec walletd curl -X GET --data-binary '{"jsonrpc": "2.0", "id": 0, "method": "generate-ec-address"}' -H 'content-type:text/plain;' http://localhost:8089/v2
```

Copy down the public address you see in the output as you will need it later. It should begin with `EC`.

**OR**

##### b. Add an entry credit address

Replace the secret key with your own secret key. It should begin with `Es`. Note: be careful not to change the formatting when copying over your secret key. Check the quotation marks.

```shell script
docker-compose exec walletd curl -X GET --data-binary '{"jsonrpc": "2.0", "id": 0, "method": "import-addresses", "params":{"addresses":[{"secret":"INSERT YOUR SECRET KEY HERE"}]}}' -H 'content-type:text/plain;' http://localhost:8089/v2
```

##### 9. Create a FCT address (if you don't already have one)

If you do not already have a FCT address, you can create one in walletd.

```shell script
docker-compose exec walletd curl -X GET --data-binary '{"jsonrpc": "2.0", "id": 0, "method": "generate-factoid-address"}' -H 'content-type:text/plain;' http://localhost:8089/v2
```

Copy down the public address, you will need it later.

#### 10. Fund your entry credit address

The cheapest way to buy entry credits is to create them yourself using FCT. You can do that using several different Factom wallets, including [MyFactomWallet](https://myfactomwallet.com/#/) (web), [Enterprise Wallet](https://docs.factomprotocol.org/wallets/enterprise-wallet) (desktop) or walletd (cli), which we have running here.

Alternatively, you can buy EC directly from [Factom Inc](https://shop.factom.com/) or [De Facto](https://ec.de-facto.pro/) who will deposit EC directly into your entry credit address.

#### 11. Configure the PegNet config file

Open the config file in a text editor.

```
nano config/pegnet.ini
```

Change the following items:

-   `ECAddress` to the public EC address created or added to the wallet in step 5.
-   `CoinbaseAddress` to your FCT address.
-   `IdentityChain` to any alphanumeric string (no spaces!) that will help you identity your miner amongst the rest.

Your miner needs to be able to get asset prices from an oracle. Complete the `[Oracle]` and `[OracleDataSources]` section of the config. The comments in the config file will guide you.

## Start

#### Starting the miners

When you start PegNet, you need to pass the number of miners you want it to run as an environment variable. Each miner will require a single CPU core.

Make sure you're in the pegnet-compose directory.

##### Local Mining

```
MINERS=4 docker-compose up -d pegnet
```


##### Network Mining

###### On coordinator machine:

```shell script
docker-compose up -d pegnet-netcoordinator
```

###### On miner machines:

You will need to edit the following setting on `config/pegnet.ini` to the IP/Port of your coordinator:
```ini
MiningCoordinatorHost=localhost:7777
```

and then

```shell script
docker-compose up -d pegnet-netminer
```


#### Checking the logs

Check the log output to make sure it is healthy. Mining will start once factomd begins to make progress, which may take a while.

```
docker-compose logs
```

The first time you start PegNet it will build a ByteMap table. This can take 10 to 15 minutes. The ByteMap table is kept on `volumes/pegnet`, so it will not need to build it again when you start it in the future.

## Stop

You can stop and remove the pegnet container without stopping factomd and walletd (for instance, if you want to change the number of miners).

```
docker stop pegnet && docker rm pegnet
```

If you ever want to take everything down.

```
docker-compose down
```

In either case, you can to bring it all back online with the [start](#start) command above.
