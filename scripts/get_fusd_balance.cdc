// get_fusd_balance.cdc

<<<<<<< HEAD
import FungibleToken from 0xee82856bf20e2aa6
import FlowToken     from 0x0ae53cb6e3f42a79
=======
import FungibleToken from 0x9a0766d93b6608b7
import FlowToken     from 0x7e60df042a9c0868
>>>>>>> merge_dev
import FUSD          from 0xe223d8a629e49c68

pub fun main(address: Address): UFix64
{
  let vaultRef = getAccount(address)
    .getCapability<&FUSD.Vault{FungibleToken.Balance}>(/public/fusdBalance)
    .borrow<>()
    ?? panic("Could not borrow Balance capability")

  return vaultRef.balance
}