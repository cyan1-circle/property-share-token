## property-share-token

**PropertyShareToken is a smart contract, which build for new hire onboarding project**

PropertyShareToken (PSH) is a revenue-sharing token designed for use in property or asset-backed smart contracts. The PSH is represents the ownership or participant right in a shared property, where property will generate the profit/rent in USDC. The holders is  entitled to receive periodic distributions in USDC based on their token holdings.

The token integrates holder tracking, USDC fund distribution, and community-based approval mechanisms.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy

```shell
$ forge script script/PropertyShareToken.s.sol:DeployPropertyShareToken --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Run Smart Contract

```shell
# get the total supply
$ cast call <contract_address> "totalSupply()" --rpc-url $RPC_URL

# token holder to approve distribution 
$ cast send <contract_address> "approveDistribution()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# distribute token fund
$ cast send <contract_address> "distributeFund()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# to deposit rent, the client need to approve contract to spend USDC in USDC first
$ cast send 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238 "approve(address, uint256)" \
0x2e92F785BbbBA9b556390Aa634243A2DBd736E5d 1000000 \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL

# then, run smart contract to deposit rent
$ cast send 0x2e92F785BbbBA9b556390Aa634243A2DBd736E5d "depositRent(uint256)" \
1000000 \
--private-key $PRIVATE_KEY \
--rpc-url $RPC_URL
```
