# updateDuckDns


# lordraw/updateduckdns

A simple updater for duckdns domain

## Needed parameter
- ***DUCKDNS_TOKEN***=autentication token duck dns
- ***DUCKDNS_DOMAIN***= domain duck dns

## Telegram webhook
- ***DUCKDNS_SENDTELEGRAM***= True for enable webhook
- ***DUCKDNS_BOTKEY***= bot key of telegram bot
- ***DUCKDNS_CHATID***= chat id of telegram


## docker run option:

### Simple:

    docker run --env DUCKDNS_TOKEN=value1 --env DUCKDNS_DOMAIN=value2 lordraw/updateduckdns:latest


### Whit env file
    docker run --env-file ./env lordraw/updateduckdns:latest

### Compose file

    name: updateduckdns
    services:
        updateduckdns:
            environment:
                - DUCKDNS_TOKEN=value1
                - DUCKDNS_DOMAIN=value2
            image: lordraw/updateduckdns:latest
