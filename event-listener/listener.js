// Copyright 2025 Circle Internet Financial Trading Company Limited.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

require('dotenv').config();
const { ethers } = require('ethers');

const RPC_URL = process.env.RPC_URL;
const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS;

const TOKEN_ABI = [
  "event Distribute(address holder, uint256 amount)",
  "event RentReceived(address sender, uint256 amount)"
];

async function main() {
    const provider = new ethers.JsonRpcProvider(RPC_URL, undefined, {polling: true});
    const contract = new ethers.Contract(CONTRACT_ADDRESS, TOKEN_ABI, provider);

    console.log(`Listening for events on contract: ${CONTRACT_ADDRESS}...`);

    // Event listener
    contract.on("Distribute", (holder, amount, event) => {
      console.log(`📢 USDC distributed to: ${holder}`);
      console.log(`💰 Amount: ${ethers.formatUnits(amount, 6)} USDC`);
      console.log(`🧾 Tx Hash: ${event.log && event.log.transactionHash}`);
      console.log("--------------------------------------------------");
    });

    contract.on("RentReceived", (sender, amount, event) => {
      console.log(`📢 USDC received from: ${sender}`);
      console.log(`💰 Amount: ${ethers.formatUnits(amount, 6)} USDC`);
      console.log(`🧾 Tx Hash: ${event.log && event.log.transactionHash}`);
      console.log("--------------------------------------------------");
    });
}

// Run the event listener
main().catch(console.error);