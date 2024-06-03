# LayerZero V2 Omni Fungible Token Bridge

The project is about LayerZero V2 Omni fungible token implementation which supports ERC20 tokens to unify alongside all EVM-compatible networks. V2 is a new branch at LayerZero recently, and there are some confusions around npm packages and Foundry releases. Here, I have merged all together and created a working ready-to-use bridge.

For simplicity, I prepared utility functions under the `./setup` folder.

## Prerequisites

The testing should start by cloning the repo. In case Foundry does not exist, we should explain how to install it, as well as the availability of the Makefile and how to install things.

1. Clone the Repository:
   
    ```sh
    git clone https://github.com/denizumutdereli/layerzerov2-blockchain-bridge
    cd layerzerov2-blockchain-bridge
    ```

2. Install Foundry if not already installed:
    ```sh
    curl -L https://foundry.paradigm.xyz | bash
    foundryup
    ```

3. Install npm packages:
    ```sh
    npm install
    ```

## Configuration

The `foundry.toml` is already set up with the necessary dependencies:


    [profile.default]
    src = 'src'
    out = 'out'
    libs = ['lib', 'node_modules']
    remappings = [
        "@openzeppelin/contracts/=node_modules/@openzeppelin/contracts/",
        "@layerzerolabs/lz-evm-protocol-v2/=node_modules/@layerzerolabs/lz-evm-protocol-v2/",
        "@layerzerolabs/lz-evm-messagelib-v2/=node_modules/@layerzerolabs/lz-evm-messagelib-v2/",
        "@layerzerolabs/lz-evm-v1-0.7/=node_modules/@layerzerolabs/lz-evm-v1-0.7/"
    ]

Before testing, it is a good idea to check folder equivalents.

## Contracts

When ready for testing, there are two contracts under the `src` folder:
- `Bridge.sol`
- `MockUsdt.sol`

In this case, we are going to use `MockUsdt`, but any ERC20 is okay.

## Deployment

I have added examples for BSC Testnet, Linea Sepolia, and Polygon Amoy. I recommend testing the bridge between BSC Testnet and Linea Sepolia due to Polygon Amoy sometimes failing, probably because it is a new infrastructure.

To deploy contracts, the example sequence is:

1. Deploy Mock USDT on BSC Testnet:

```cmd
    make deploy_mockusdt_bscTestnet
```
 - This deploys the mock USDT. We should copy the deployed address and update the `.env`:
    BSCT_TESTNET_MOCKUSDT_GENERIC=<deployed_address>

1. Deploy the Bridge contract on BSC Testnet:
   
```cmd
    make deploy_bridge_bscTestnet
```

 - After deployment, we should copy the address and update the `.env`:
    BSC_TESTNET_BRIDGE=<deployed_address>

Since LayerZero requires bytes32 with left 0 padding for peer engaging settings, we now produce a bytes32 left 0 padded content. I have added a help function for it. Usage is simple:

 ```cmd
    make to_bytes32 address=0xTheBridgeAddressDeployedRecently
 ```

We will repeat this for Linea Sepolia and set the `.env` correspondingly.

## Bridge Setup

After we deploy the bridges and update the `.env` file accordingly, it is time to connect the bridges together and update the last settings.

1. Set peer connections:

 ```cmd
    make set-peer-lineaSepolia-bscTestnet

    make set-peer-bscTestnet-lineaSepolia
 
 ```

 - These commands tell the bridges to acknowledge each other.

1. Verify peer acknowledgments:

 ```cmd

    make verify-peer-bscTestnet-lineaSepolia

    make verify-peer-lineaSepolia-bscTestnet

 ```
 
 - These should return true / `address(1)`.

This is not written everywhere and might be hard to find, but I found out that it is a must in V2. So we have set these settings in all bridges for targeting bridges. Basically, it tells the bridges what type of transition we are having (in this case, it's 1) and the gas limit.

    //OptionBuilder.addExecutorLzReceiveOption(1500000,1)
    // The above contract implementation generates the following hash, and this is standard, so it means we don't need to worry about the above logic but can use the below hash. In LayerZero, remaining gas will always be refunded. So it's safe.
    0x00030100110100000000000000000000000000030d40

1. Set enforced options:

 ```cmd

    make set-enforced-option-bscTestnet-lineaSepolia

    make set-enforced-option-lineaSepolia-bscTestnet

 ```

## Testing

For testing, we need to transfer a sufficient amount of mock USDT to the bridges. Therefore, the following commands will send and approve the receive and transfer abilities to the bridges.

1. Transfer test supply and set allowances:

 ```cmd

    make transfer_test_supply_bscTestnet

    make allowance_bscTestnet

    make transfer_test_supply_lineaSepolia

    make allowance_lineaSepolia

```

2. Estimate gas:

 ```cmd
    make estimate_gas_bscTestnet_lineaSepolia

    make estimate_gas_lineaSepolia_bscTestnet
 ```

Now we are ready for testing:

Sending 100 USDT, BSC Testnet to Linea Sepolia:
 
 ```cmd
    make send_from_bscTestnet_to_lineaSepolia
 ```

Sending 100 USDT, Linea Sepolia to BSC Testnet:

 ```cmd
    make send_from_lineaSepolia_to_bscTestnet
 ```

These commands will print the transaction hash to the console. You can copy those hashes and trace from LayerZero scan via address:
[LayerZero Scan](https://testnet.layerzeroscan.com/)

When a successful transfer occurs, for example, A to B, A will receive tokens from the sender, and when the message arrives at network B, B will send the same token to the sender.

Lastly, and importantly, I want to mention to look closely at how the bridge function is triggering:

 ```cmd
    cast send ${LINEA_SEPOLIA_BRIDGE} "send((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),(uint,uint),address)" "(${BSC_TESTNET_LZ_CHAINID}, ${BSC_TESTNET_BYTES32}, \
        100000000,100000000,0x,0x,0x)" "(10000000000000000,0)" ${DELEGATE_ADDRESS} \
        --rpc-url ${LINEA_SEPOLIA_RPC_URL}${INFURA_PROJECT_ID} \
        --private-key ${PRIVATE_KEY} \
        --value 0.01ether
 ```

This gas fee definition `"(10000000000000000,0)"` should exactly be the same as the parameter `--value 0.01ether`. I found out that, it's not written somewhere, but the inherited LayerZero V2 protocol has the following function not mentioned anywhere:

 ```sol
    function _payNative(uint256 _nativeFee) internal virtual returns (uint256 nativeFee) {
        if (msg.value != _nativeFee) revert NotEnoughNative(msg.value);
        return _nativeFee;
    }
 ```

So if this first parameter is not exactly the same, you will always get reverted and don't know why.

`"(10000000000000000,0)"`  `--value 0.01ether`

## Contributing

Contributions to expand or improve the repository are welcome! 

[@denizumutdereli](https://www.linkedin.com/in/denizumutdereli)
