// get_TokenA_balance.cdc

import FungibleToken from 0xee82856bf20e2aa6
import FlowToken     from 0x0ae53cb6e3f42a79
import TokenA          from 0xec4809cd812aee0a

pub fun main(address: Address): UFix64?
{
  let vaultRef = getAccount(address)
    .getCapability<&TokenA.Vault{FungibleToken.Balance}>(/public/TokenABalance)
    .borrow<>()
    //?? panic("Could not borrow Balance capability")

  return vaultRef?.balance
}