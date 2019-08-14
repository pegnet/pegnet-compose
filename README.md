# PegNet Compose

PegNet Compose leverages Docker Compose to help you start and manage a PegNet miner.

_NOTE: PegNet Compose is currently configured to join the PegNet testnet. This will be updated when mainnet is launched._

## Requirements

-   [Docker Engine 1.13.0+](https://docs.docker.com/install/)
-   [Docker Compose](https://docs.docker.com/compose/install/)

## Setup

This is the initial setup process. You will only need to do this once.

#### 1. Clone and cd into this repo

```
git clone https://github.com/pegnet/pegnet-compose.git && cd pegnet-compose
```

#### 2. Create Docker volumes

PegNet Compose uses 3 Docker volumes to persist data.

```
docker volume create factom_database
docker volume create factom_wallet
docker volume create pegnet
```

#### 3. Create a factomd.conf

It is necessary to create a factomd.conf file in the config folder. The default settings should work out of the box for most people.

```
cp config/factomd.conf.EXAMPLE config/factomd.conf
```

#### 4. Start factomd and walletd

Begin syncing the blockchain and start the wallet. This command looks like it only brings walletd up, but it brings factomd up too.

```
docker-compose run --name walletd -d walletd
```

#### 5. Create or add an entry credit address

##### a. Create an entry credit address

```
docker exec -it walletd \
curl -X GET \
--data-binary '{"jsonrpc": "2.0", "id": 0, "method": "generate-ec-address"}' \
-H 'content-type:text/plain;' http://localhost:8089/v2
```

Copy down the public address you see in the output as you will need it later. It should begin with `EC`.

**OR**

##### b. Add an entry credit address

Replace the secret key with your own secret key. It should begin with `Es`. Note: be careful not to change the formatting when copying over your secret key. Check the quotation marks.

```
docker exec -it walletd \
curl -X GET --data-binary \
'{"jsonrpc": "2.0", "id": 0, "method": "import-addresses", "params":{"addresses":[{"secret":"Es3tXbGBVKZDhUWzDKzQtg4rcpmmHPXAY9vxSM2JddwJSD5td3f8"}]}}' \
-H 'content-type:text/plain;' http://localhost:8089/v2
```

#### 6. OPTIONAL: Create or add a FCT address

If you do not already have a FCT address, you can create one in walletd.

```
docker exec -it walletd \
curl -X GET \
--data-binary '{"jsonrpc": "2.0", "id": 0, "method": "generate-factoid-address"}' \
-H 'content-type:text/plain;' http://localhost:8089/v2
```

Copy down the public address, you will need it later.

#### 7. Fund your entry credit address

The cheapest way to buy entry credits is to create them yourself using FCT. You can do that using several different Factom wallets, including [MyFactomWallet](https://myfactomwallet.com/#/) (web), [Enterprise Wallet](https://docs.factomprotocol.org/wallets/enterprise-wallet) (desktop) or walletd (cli), which we have running here.

Alternatively, you can buy EC directly from [Factom Inc](https://shop.factom.com/) or [De Facto](https://ec.de-facto.pro/) who will deposit EC directly into your entry credit address.

#### 8. Create the PegNet config file

Copy the example config file to use as a template.

```
cp config/pegnet.ini.EXAMPLE config/pegnet.ini
```

Open the config file in a text editor.

```
nano config/pegnet.ini
```

Change the following items:

-   `ECAddress` to the public EC address created or added to the wallet in step 5.
-   `FCTAddress` and `CoinbaseAddress` to your FCT address.
-   `IdentityChain` to any alphanumeric string (no spaces!) that will help you identity your miner amongst the rest.

Your miner needs to be able to get asset prices from an oracle. The oracles are `APILayer`, `ExchangeRatesAPI` and `OpenExchangeRates`. To use an oracle, change the setting from 0 to 1. For example:

```
APILayer=1
ExchangeRatesAPI=0
OpenExchangeRates=0
```

Finally, you need to get an API key for your chosen oracle.

-   An `OpenExchangeRatesKey` can be obtained [here](https://openexchangerates.org/).
-   An `APILayerKey` csn be obtained [here](https://currencylayer.com/).

#### 9. Wait for factomd to finish syncing

The initial sync might take anywhere from 12 to 48 hours. You can close the shell whilst this is happening if you wish.

You will be able to see the progress of the factomd sync in your web browser by visiting `host:8090`, where `host` is the IP address of your machine. If you're doing this on your local machine, `host` will be `localhost`.

You can also track it at the command line with the following command.

```
docker exec -it factomd \
curl -X POST --data-binary \
'{"jsonrpc": "2.0", "id": 0, "method": "heights"}' -H 'content-type:text/plain;' http://localhost:8088/v2
```

It has finished syncing when all the heights are the same.

#### 10. Stop and remove the running containers

We'll bring everything back up at the same time later when starting PegNet.

```
docker-compose down
```

## Start

When you start PegNet, you need to pass the number of miners you want it to run as an environment variable. Each miner will require a single CPU core.

Make sure you're in the pegnet-compose directory.

```
MINERS=4 docker-compose up -d
```

Check the log output to make sure it is healthy.

```
docker-compose logs
```

The first time you start PegNet it will build a ByteMap table. This can take 10 to 15 minutes. The ByteMap table is persisted to disc, so it will not need to build it again when you start it in the future.

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
