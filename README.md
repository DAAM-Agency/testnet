# DAAM_V11 Agency
## (Digital Art & Assets Management)
daam.agency[https://daam.agency]

## About
We work hand-in-hand with creators, galleries, institutions + private collectors, to realize their NFT goals. We choose Flow over Ethereum due to Ethereums the size limts, transfer time and rates issues regarding the NFT Market, despite the Solidity experience in house. We created an agency to bridge the gap between seller, creators, and the general public. While exposing our DAAM_V11 NFTs at selected events.

The DAAM_V11 Auction House and DAAM_V11 NFT are written in Cadence for the Flow blockchain. For more information on Flow and Cadence visit the at [https://docs.onflow.org/] 

## Files
The two contracts are ./contracts/daam.cdc and ./contracts/auction.cdc. The NFT data structure, Agency, Collection, Minter, Creator, Admin, Founder, etc resources and interfaces are found in the daam.cdc file

The auction.cdc file contains all auction related Cadence code.

The init.sh file contains basic testing accounts with flow and publishes the contracts
While the transactions.sh file runs through most of the transactions scripts. Examples of how to run tranactions and scripts can be found here.

## Prerequisites
Flow Client [https://docs.onflow.org/flow-cli/install/#gatsby-focus-wrapper]
Cadence

## Install
Installing the daam.cdc contract must be done as a flow transaction since the contract has arguments.
Ex: 
export HEX_ENCODE_CODE=$(cat ../dev/hex_nft_enum)
flow transactions send ../testnet_keys/init_DAAM_V11_Agency.cdc --arg String:"DAAM_V11" --arg String:$HEX_ENCODE_CODE --arg Address:$AGENCY --arg Address:$CTO --signer daam_nft


