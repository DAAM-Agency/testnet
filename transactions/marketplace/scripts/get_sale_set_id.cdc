import Market from 0x045a1763c93006ca

pub fun main(sellerAddress: Address, tokenID: UInt64): UInt32 {
    let saleRef = getAccount(sellerAddress).getCapability(Market.marketPublicPath)
        .borrow<&{Market.SalePublic}>()
        ?? panic("Could not get public sale reference")

    let token = saleRef.borrowNFT(id: tokenID)
        ?? panic("Could not borrow a reference to the specified moment")

    let data = token.data

    return data.setID
}