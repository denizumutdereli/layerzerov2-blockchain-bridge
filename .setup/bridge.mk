# - transfer test supply-------------------------------------------------------------------- -

transfer_test_supply_polygonAmoy:
	cast send ${POLYGON_AMOY_TESTNET_MOCKUSDT_GENERIC} "transfer(address,uint256)" ${POLYGON_AMOY_BRIDGE} 1000000000000 \
		--rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY}

allowance_polygonAmoy:
	cast send ${POLYGON_AMOY_TESTNET_MOCKUSDT_GENERIC} "approve(address,uint256)" ${POLYGON_AMOY_BRIDGE} 10000000000 \
		--rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY}

transfer_test_supply_bscTestnet:
	cast send ${BSCT_TESTNET_MOCKUSDT_GENERIC} "transfer(address,uint256)" ${BSC_TESTNET_BRIDGE} 1000000000000 \
		--rpc-url ${BSC_TESTNET_RPC_URL} \
		--private-key ${PRIVATE_KEY}

allowance_bscTestnet:
	cast send ${BSCT_TESTNET_MOCKUSDT_GENERIC} "approve(address,uint256)" ${BSC_TESTNET_BRIDGE} 10000000000 \
		--rpc-url ${BSC_TESTNET_RPC_URL} \
		--private-key ${PRIVATE_KEY}

transfer_test_supply_lineaSepolia:
	cast send ${LINEA_SEPOLIA_MOCKUSDT_GENERIC} "transfer(address,uint256)" ${LINEA_SEPOLIA_BRIDGE} 1000000000000 \
		--rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY}

allowance_lineaSepolia:
	cast send ${LINEA_SEPOLIA_MOCKUSDT_GENERIC} "approve(address,uint256)" ${LINEA_SEPOLIA_BRIDGE} 10000000000 \
		--rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY}

# - estimate gas price---------------------------------------------------------------------- -

estimate_gas_polygonAmoy_bscTestnet:
	cast call ${POLYGON_AMOY_BRIDGE} "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)(uint,uint)" "(${BSC_TESTNET_LZ_CHAINID}, ${BSC_TESTNET_BYTES32}, \
	100000000,100000000, ${LZ_OPTION_BUILDERHEX},0x,0x)" false \
	--rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID}

estimate_gas_bscTestnet_polygonAmoy:
	cast call ${BSC_TESTNET_BRIDGE} "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)(uint,uint)" "(${POLYGON_AMOY_LZ_CHAINID}, ${POLYGON_AMOY_BYTES32}, \
	100000000,100000000, ${LZ_OPTION_BUILDERHEX},0x,0x)" false \
	--rpc-url ${BSC_TESTNET_RPC_URL}

estimate_gas_bscTestnet_lineaSepolia:
	cast call ${BSC_TESTNET_BRIDGE} "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)(uint,uint)" "(${LINEA_SEPOLIA_LZ_CHAINID}, ${LINEA_SEPOLIA_BYTES32}, \
	100000000,100000000, ${LZ_OPTION_BUILDERHEX},0x,0x)" false \
	--rpc-url ${BSC_TESTNET_RPC_URL}

estimate_gas_lineaSepolia_bscTestnet:
	cast call ${LINEA_SEPOLIA_BRIDGE} "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)(uint,uint)" "(${BSC_TESTNET_LZ_CHAINID}, ${BSC_TESTNET_BYTES32}, \
	100000000,100000000, ${LZ_OPTION_BUILDERHEX},0x,0x)" false \
	--rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID}

# - test the bridge ------------------------------------------------------------------------ -

send_from_bscTestnet_to_lineaSepolia:
	cast send ${BSC_TESTNET_BRIDGE} "send((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),(uint,uint),address)" "(${LINEA_SEPOLIA_LZ_CHAINID}, ${LINEA_SEPOLIA_BYTES32}, \
	100000000,100000000,0x,0x,0x)" "(10000000000000000,0)" ${DELEGATE_ADDRESS} \
	--rpc-url ${BSC_TESTNET_RPC_URL} \
	--private-key ${PRIVATE_KEY} \
	--value 0.01ether

send_from_lineaSepolia_to_bscTestnet:
	cast send ${LINEA_SEPOLIA_BRIDGE} "send((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),(uint,uint),address)" "(${BSC_TESTNET_LZ_CHAINID}, ${BSC_TESTNET_BYTES32}, \
		100000000,100000000,0x,0x,0x)" "(10000000000000000,0)" ${DELEGATE_ADDRESS} \
		--rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID} \
		--private-key ${PRIVATE_KEY} \
		--value 0.01ether

