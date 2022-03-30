pub contract Neogotiator {
    // Events
    pub event RequestRoyality(agency: Address, mid: UInt64)
    pub event RequestPrice(agency: Address, mid: UInt64)
    pub event RequestPercentage(agency: Address, mid: UInt64)
    
    // Functions
    pub fun makeRequest(type: RequestType): @{Request} {
        switch(type) {
            case RequestType.ROYALITY:
                return <- create Royality(d: mid)
            case RequestType.PRICE:
                return <- create Price(agency: agency, mid: mid)
        }
    }
/************************************************************************/
    pub enum RequestType: UInt8 {
        pub case ROYALITY
        pub case PRICE
    }
/************************************************************************/
    pub resource interface Request  {
        pub let type: RequestType // Royality or Price
        pub var open: Bool?  // true=sender turn to decide, false=receiver turn to decide, nil=finalized deal
    }
/************************************************************************/
    pub resource Royality: Request {
        pub let type: RequestType
        pub var open: Bool?

        priv var royality: {&{Partner} : UFix64} // {Royality address : Percenrage (0.15)}

        init(agency: &Agency, mid: UInt64, royality: {&{Partner} : UFix64}) {
            pre { agency.mid.contains(mid) : "Incorrect Metadata ID" }
            // Request Interface
            self.type = RequestType.ROYALITY
            self.open = true
            // Royality
            self.royality = royality

            emit RequestRoyality(agency: agency.aid, mid: mid)
        }

        pub fun acceptDefault() {
            self.royality = { agency.account?.owner! : 0.1 as UFix64 }
            self.royality.insert(key: self.owner?.address!, 0.2 )
        }

        pub fun set() {
            // is it 
        }
    }
/************************************************************************/
    pub resource Price: Request {
        pub let type: RequestType
        pub var open: Bool?

        priv var price: {&{Partner} : UFix64}

        init(agency: &Agency, mid: UInt64, price: {&{Partner} : UFix64}) {
            pre { agency.mid.contains(mid) : "Incorrect Metadata ID" }
            // Request Interface
            self.type = RequestType.PRICE
            self.open = true
            // Price
            self.price = price

            emit RequestPrice(agency: agency.aid, mid: mid)
        }
    }
/************************************************************************/
    pub resource Percentage: Request {
        pub let type: RequestType
        pub var open: Bool?

        priv var percentage: {&{Partner} : UFix64}

        init(agency: &Agency, mid: UInt64, percentage: {&{Partner} : UFix64}) {
            pre { 
                agency.mid.contains(mid) : "Incorrect Metadata ID"
                percentage < 1.0 : "Must be less the 100%"
            }
            // Request Interface
            self.type = RequestType.PRICE
            self.open = true
            // Percentage
            self.percentage = {}

            emit RequestPercentage(agency: agency.aid, mid: mid)
        }
    }
/************************************************************************/
}// End Neogotiator