# SupplyChain--Solidity-Truffle
This repository contains a  general Supply Chain smart contract developed in Solidity.
### Features
+ **Product Registration:** Allows registering new products in the supply chain with specific prices associated with different lifecycle states of the product.
+ **Step Registration:** Enables recording different stages of a product's lifecycle, including its creation, pick-up, preparation for delivery, and final delivery.
+ **Secure Transactions:** Ensures that necessary payments are made to the author of each step before registering the next step.
+ **Public Queries**: Provides functions to query the details and number of steps a product has gone through, as well as the price associated with a specific status.

### Installation
1. Clone the repository:
```
git clone https://github.com/alvarodzglez/SupplyChain--Solidity-Truffle.git
cd supply-chain
```
2. Install dependencies:
```
npm install
```

### Usage
1. Compile the contracts:
```
truffle compile
```
2. Start Ganache:
```
ganache-cli
```
3. Deploy the contracts to Ganache:
```
truffle migrate --network development
```
4. Interact with the contract using the Truffle console:
```
truffle console --network development
```
Example commands in the Truffle console:

```
// Get the deployed contract instance
const supplyChain = await SupplyChain.deployed();

// Register a new product
await supplyChain.registerProduct(1, web3.utils.toWei('1', 'ether'), web3.utils.toWei('1.5', 'ether'), web3.utils.toWei('2', 'ether'), web3.utils.toWei('2.5', 'ether'));

// Register a new step
await supplyChain.registerStep(1, "Product picked up", { value: web3.utils.toWei('1', 'ether') });

// Get details of the first step
const step = await supplyChain.getStep(1, 0);
console.log(step);

// Get the number of steps a product has gone through
const stepsCount = await supplyChain.getStepsCount(1);
console.log(stepsCount);
```
### Contributions
Contributions are welcome! Feel free to open issues or pull requests for improvements and bug fixes.

### License
This project is licensed under the MIT License. See the LICENSE file for more details.