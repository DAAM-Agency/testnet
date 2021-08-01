import FungibleToken    from 0xee82856bf20e2aa6
import NonFungibleToken from 0x120e725050340cab
import DAAM             from 0xfd43f9148d4b725d

pub fun main(account: Address): [UInt64] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")

    return collectionRef.getIDs()
}
