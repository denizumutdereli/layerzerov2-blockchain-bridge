# - BSC_TESTNET----------------------------------------------------------------------------- #
# - deploy --------------------------------------------------------------------------------- -

deploy_mockusdt_bscTestnet:
	forge create src/MockUSDT.sol:MockUSDT \
		--rpc-url ${BSC_TESTNET_RPC_URL} \
		--private-key ${PRIVATE_KEY}

deploy_bridge_bscTestnet:
	forge create src/Bridge.sol:Bridge \
		--rpc-url ${BSC_TESTNET_RPC_URL} \
		--private-key ${PRIVATE_KEY} \
		--constructor-args ${BSCT_TESTNET_MOCKUSDT_GENERIC} ${BSC_TESTNET_LZ_ENDPOINT} ${DELEGATE_ADDRESS}

# - verify contracts ----------------------------------------------------------------------- -

verify_mockusdt_bscTestnet:
	forge verify-contract --chain-id ${BSC_TESTNET_CHAINID} \
		--watch ${BSCT_TESTNET_MOCKUSDT_GENERIC} src/MockUSDT.sol:MockUSDT \
		--etherscan-api-key ${BSCTESTNET_API_KEY} \
		--verifier-url ${BSC_TESTNET_VERIFY_API} \

verify_bridge_bscTestnet:
	forge verify-contract --chain-id ${BSC_TESTNET_CHAINID} \
		--watch ${BSC_TESTNET_BRIDGE} src/Bridge.sol:Bridge \
		--etherscan-api-key ${BSCTESTNET_API_KEY} \
		--verifier-url ${BSC_TESTNET_VERIFY_API} \
