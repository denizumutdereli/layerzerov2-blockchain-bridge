# - POLYGON_AMOY --------------------------------------------------------------------------- #
# - deploy --------------------------------------------------------------------------------- -

deploy_mockusdt_polygonAmoy:
	forge create src/MockUSDT.sol:MockUSDT \
		--rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY}

deploy_bridge_polygonAmoy:
	forge create src/Bridge.sol:Bridge \
		--rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY} \
		--constructor-args ${POLYGON_AMOY_TESTNET_MOCKUSDT_GENERIC} ${POLYGON_AMOY_LZ_ENDPOINT} ${DELEGATE_ADDRESS}

# - verify contracts ----------------------------------------------------------------------- -

verify_mockusdt_polygonAmoy:
	forge verify-contract --chain-id ${POLYGON_AMOY_CHAINID} \
		--watch ${POLYGON_AMOY_TESTNET_MOCKUSDT_GENERIC} src/MockUSDT.sol:MockUSDT \
		--etherscan-api-key ${POLYGONSCAN_API_KEY} \
		--verifier-url ${POLYGON_AMOY_VERIFY_API}

verify_bridge_polygonAmoy:
	forge verify-contract --chain-id ${POLYGON_AMOY_CHAINID} \
		--watch ${POLYGON_AMOY_BRIDGE} src/Bridge.sol:Bridge \
		--etherscan-api-key ${POLYGONSCAN_API_KEY} \
		--verifier-url ${POLYGON_AMOY_VERIFY_API}
