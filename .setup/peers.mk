# - peer settings--------------------------------------------------------------------------- -

# cast to-bytes32 address
# 0x6edce65403992e310a62460808c4b910d972f10f000000000000000000000000
# 000000000000000000000000006edce65403992e310a62460808c4b910d972f10f -> check if bytes32 address padding from right shifted

# cross pairing settings
set-peer-polygonAmoy-bscTestnet:
	cast send ${POLYGON_AMOY_BRIDGE} "setPeer(uint32,bytes32)" ${BSC_TESTNET_LZ_CHAINID} ${BSC_TESTNET_BYTES32} --rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID} --private-key ${PRIVATE_KEY}

set-peer-bscTestnet-polygonAmoy:
	cast send ${BSC_TESTNET_BRIDGE} "setPeer(uint32,bytes32)" ${POLYGON_AMOY_LZ_CHAINID} ${POLYGON_AMOY_BYTES32} --rpc-url ${BSC_TESTNET_RPC_URL} --private-key ${PRIVATE_KEY}

set-peer-lineaSepolia-bscTestnet:
	cast send ${LINEA_SEPOLIA_BRIDGE} "setPeer(uint32,bytes32)" ${BSC_TESTNET_LZ_CHAINID} ${BSC_TESTNET_BYTES32} --rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID} --private-key ${PRIVATE_KEY}

set-peer-bscTestnet-lineaSepolia:
	cast send ${BSC_TESTNET_BRIDGE} "setPeer(uint32,bytes32)" ${LINEA_SEPOLIA_LZ_CHAINID} ${LINEA_SEPOLIA_BYTES32} --rpc-url ${BSC_TESTNET_RPC_URL} --private-key ${PRIVATE_KEY}

# verify & check peers if they are working
verify-peer-polygonAmoy-bscTestnet:
	cast call ${POLYGON_AMOY_BRIDGE} "isPeer(uint32,bytes32)" ${BSC_TESTNET_LZ_CHAINID} ${BSC_TESTNET_BYTES32} --rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID}

verify-peer-bscTestnet-polygonAmoy:
	cast call ${BSC_TESTNET_BRIDGE} "isPeer(uint32,bytes32)" ${POLYGON_AMOY_LZ_CHAINID} ${POLYGON_AMOY_BYTES32} --rpc-url ${BSC_TESTNET_RPC_URL}

verify-peer-bscTestnet-lineaSepolia:
	cast call ${BSC_TESTNET_BRIDGE} "isPeer(uint32,bytes32)" ${LINEA_SEPOLIA_LZ_CHAINID} ${LINEA_SEPOLIA_BYTES32} --rpc-url ${BSC_TESTNET_RPC_URL}

verify-peer-lineaSepolia-bscTestnet:
	cast call ${LINEA_SEPOLIA_BRIDGE} "isPeer(uint32,bytes32)" ${BSC_TESTNET_LZ_CHAINID} ${BSC_TESTNET_BYTES32} --rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID}

# check balances
check-balance-polygonAmoy:
	cast call ${POLYGON_AMOY_BRIDGE} "totalSupply()(uint256)" --rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID}

check-balance-bscTestnet:
	cast call ${BSC_TESTNET_BRIDGE} "totalSupply()(uint256)" --rpc-url ${BSC_TESTNET_RPC_URL}

check-balance-lineaSepolia:
	cast call ${LINEA_SEPOLIA_BRIDGE} "totalSupply()(uint256)" --rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID}

# setting configs
set-enforced-option-polygonAmoy-bscTestnet:
	cast send ${POLYGON_AMOY_BRIDGE} "setEnforcedOptions((uint32,uint16,bytes)[])" "[(${BSC_TESTNET_LZ_CHAINID},1,${LZ_OPTION_BUILDERHEX})]" --rpc-url ${POLYGON_AMOY_RPC_URL}${INFURA_PROJECT_ID} --private-key ${PRIVATE_KEY}

set-enforced-option-bscTestnet-polygonAmoy:
	cast send ${BSC_TESTNET_BRIDGE} "setEnforcedOptions((uint32,uint16,bytes)[])" "[(${POLYGON_AMOY_LZ_CHAINID},1,${LZ_OPTION_BUILDERHEX})]" --rpc-url ${BSC_TESTNET_RPC_URL} --private-key ${PRIVATE_KEY}

set-enforced-option-bscTestnet-lineaSepolia:
	cast send ${BSC_TESTNET_BRIDGE} "setEnforcedOptions((uint32,uint16,bytes)[])" "[(${LINEA_SEPOLIA_LZ_CHAINID},1,${LZ_OPTION_BUILDERHEX})]" --rpc-url ${BSC_TESTNET_RPC_URL} --private-key ${PRIVATE_KEY}

set-enforced-option-lineaSepolia-bscTestnet:
	cast send ${LINEA_SEPOLIA_BRIDGE} "setEnforcedOptions((uint32,uint16,bytes)[])" "[(${BSC_TESTNET_LZ_CHAINID},1,${LZ_OPTION_BUILDERHEX})]" --rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID} --private-key ${PRIVATE_KEY}
