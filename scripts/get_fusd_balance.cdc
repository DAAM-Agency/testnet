// get_fusd_balance.cdc

import FungibleToken from 0xee82856bf20e2aa6
import FlowToken     from 0x0ae53cb6e3f42a79
import FUSD          from 0x192440c99cb17282

pub fun main(address: Address): UFix64?
{
  let vaultRef = getAccount(address)
    .getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance)
    .borrow<>()
    //?? panic("Could not borrow Balance capability")

  return vaultRef?.balance
}