import Market from 0x045a1763c93006ca

pub fun main(sellerAddress: Address): UFix64 {
    let acct = getAccount(sellerAddress)
    let collectionRef = acct.getCapability(Market.marketPublicPath).borrow<&{Market.SalePublic}>()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.cutPercentage
}