// create_multitoken_manager.cdc
// Checks for a MultiTokenManager. Return true if found, otherwise return false.


import MultiToken from 0x0f7025fa05b578e3

pub fun main(acount: Address): Bool {
   return (getAccount(account).getCapability(MultiToken.MultiTokenManager<FungibleToken.Receiver>).borrow() != nil)
}
