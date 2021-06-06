import Market   from 0xe2f72218abeec2b9

pub fun main(sellerAddress: Address, tokenID: UInt64): UFix64 {

    let acct = getAccount(sellerAddress)
    let collectionRef = acct.getCapability(Market.marketPublicPath).borrow<&{Market.SalePublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getPrice(tokenID: UInt64(tokenID))!
    
}