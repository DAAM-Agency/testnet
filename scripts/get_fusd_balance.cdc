// get_fusd_balance.cdc

import FungibleToken from 0x9a0766d93b6608b7
import FlowToken     from 0x0ae53cb6e3f42a79
import FUSD          from 0x0bb80b2a4cb38cdf

pub fun main(address: Address): UFix64?
{
  let vaultRef = getAccount(address)
    .getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance)
    .borrow<>()
    //?? panic("Could not borrow Balance capability")

  return vaultRef?.balance
}