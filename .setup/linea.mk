# - LINEA_SEPOLIA_TESTNET------------------------------------------------------------------- #
# - deploy --------------------------------------------------------------------------------- -

deploy_mockusdt_lineaSepolia:
	forge create src/MockUSDT.sol:MockUSDT \
		--rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY}

deploy_bridge_lineaSepolia:
	forge create src/Bridge.sol:Bridge \
		--rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY} \
		--constructor-args ${LINEA_SEPOLIA_MOCKUSDT_GENERIC} ${LINEA_SEPOLIA_LZ_ENDPOINT} ${DELEGATE_ADDRESS}

# - verify contracts ----------------------------------------------------------------------- -

verify_mockusdt_lineaSepolia:
	forge verify-contract --chain-id ${LINEA_SEPOLIA_LZ_CHAINID} \
		--watch ${LINEA_SEPOLIA_MOCKUSDT_GENERIC} src/MockUSDT.sol:MockUSDT \
		--etherscan-api-key ${LINEA_SEPOLIA_API_KEY} \
		--verifier-url ${LINEA_SEPOLIA_VERIFY_API} \

verify_bridge_lineaSepolia:
	forge verify-contract --chain-id ${LINEA_SEPOLIA_LZ_CHAINID} \
		--watch ${LINEA_SEPOLIA_BRIDGE} src/Bridge.sol:Bridge \
		--etherscan-api-key ${LINEA_SEPOLIA_API_KEY} \
		--verifier-url ${LINEA_SEPOLIA_VERIFY_API} \
