import Marketplace from 0x045a1763c93006ca

transaction(receiverPath: PublicPath) {
    prepare(acct: AuthAccount) {

        let saleCollection = acct.borrow<&Marketplace.SaleCollection>(from: Marketplace.marketStoragePath)
            ?? panic("Could not borrow from sale in storage")

        saleCollection.changeOwnerReceiver(acct.getCapability(receiverPath))
    }
}