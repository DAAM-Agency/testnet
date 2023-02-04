// get_fusd_balance.cdc

import FungibleToken from 0xf233dcee88fe0abe
import FlowToken     from 0x1654653399040a61
import FUSD          from 0x3c5959b568896393

pub fun main(address: Address): UFix64?
{
  let vaultRef = getAccount(address)
    .getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance)
    .borrow<>()
    //?? panic("Could not borrow Balance capability")

  return vaultRef?.balance
}
