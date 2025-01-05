```shell
# Account setup
PK=...
ACCOUNT=dev
cast wallet import --private-key $PK $ACCOUNT

# Forge scripts
FORK_URL=...
ETHERSCAN_API_KEY=...
MSG_SENDER=...

# Example command to deploy a proxy contract
forge script script/deploy_proxy.sol:ProxyScript \
--rpc-url $FORK_URL \
-vvv \
--keystore ~/.foundry/keystores/my_keystore.json \
--sender $MSG_SENDER \
--broadcast \
--verify \
--etherscan-api-key $ETHERSCAN_API_KEY
```

### FlashLev scripts

0. Setup wallet with `cast`
1. Edit [configuration](./script/config.sol)
2. Deploy proxy ([script](./script/deploy_proxy.sol))
3. Approve token transfers ([script](./script/approve.sol))
4. Open position ([script](./script/open.sol))
5. Monitor stats ([script](./script/stats.sol))
6. Close position ([script](./script/close.sol))
