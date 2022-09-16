// get_fusd_balance.cdc

import FungibleToken from 0x9a0766d93b6608b7
import FlowToken     from 0x7e60df042a9c0868
<<<<<<< HEAD
import FUSD          from 0xe223d8a629e49c68
=======
import FUSD          from 0x0xe223d8a629e49c68
>>>>>>> tomerge

pub fun main(address: Address): UFix64?
{
  let vaultRef = getAccount(address)
    .getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance)
    .borrow<>()
    //?? panic("Could not borrow Balance capability")

  return vaultRef?.balance
}