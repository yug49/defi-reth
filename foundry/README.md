```shell
# Account setup
PK=...
ACCOUNT=dev
cast wallet import --private-key $PK $ACCOUNT

# Deploy
FORK_URL=...
ETHERSCAN_API_KEY=...
MSG_SENDER=...

forge script script/deploy_proxy.sol:ProxyScript \
--rpc-url $FORK_URL \
-vvv \
--keystore ~/.foundry/keystores/my_keystore.json \
--sender $MSG_SENDER \
--broadcast \
--verify \
--etherscan-api-key $ETHERSCAN_API_KEY
```

- Proxy 0xC5aCD8c4604476FEFfd4bEb164a22f70ed56884D
- FlashLev 0xDcc6Dc8D59626E4E851c6b76df178Ab0C390bAF8
