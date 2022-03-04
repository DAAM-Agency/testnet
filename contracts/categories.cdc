pub contract Categories {
    // events
    pub event CategoryAdded(name: String, id: UInt64)
    pub event CategoryRemoved(name: String, id: UInt64)

    // struct
    pub struct Category {
        pub let name: String
        pub let id: UInt64

        init(name: String) {
            pre { Categories.categories.containsKey(name) }
            self.name = name
            self.id = Categories.categories[name]!
        }
    }

    // variables
    priv let grantee: Address
    priv var counter   : UInt64            // A counter used as an incremental Category ID
    access(contract) var categories: {String : UInt64} // category list { category name : categoty counter (acts as ID)}

    // functions
    // Get Catagories by a list of names or as {name: category id}
    pub fun getCategories(): [String] { return self.categories.keys }
    pub fun getCategoriesFull(): {String : UInt64} { return self.categories }

    // Get category name by using Category ID
    pub fun getCategoryName(id: UInt64): String? {
        pre { id < self.counter : "Invalid Category #" }

        for cat in self.categories.keys {
            if self.categories[cat] == id { return cat }
        }
        return nil
    }

    // Get category name by using Category ID
    pub fun getCategoryID(name: String): UInt64 {
        pre { self.categories.containsKey(name) : "Invalid Category" }
        return self.categories[name]!
    }

    // management functions
    
    pub fun addCategory(_ signer: AuthAccount, name: String) {
        pre {
            signer.address == self.grantee : "Not Authorized!"
            !self.categories.containsKey(name) : "Category: ".concat(name).concat(" already exists.")
        }
        post{ self.categories.containsKey(name) : "Internal Error: Add Category" }

        self.categories.insert(key: name, self.counter)
        self.counter = self.counter + 1
        emit CategoryAdded(name: name, id: self.counter)
    }

    pub fun removeCategory(_ signer: AuthAccount, name: String) {
        pre {
            signer.address == self.grantee : "Not Authorized!"
            self.categories.containsKey(name) : "Category: ".concat(name).concat(" does not exists.")
        }
        post{ !self.categories.containsKey(name) : "Internal Error: Remove Category" }

        self.categories.remove(key: name)
        emit CategoryRemoved(name: name, id: self.counter)
    }

    init(signer: AuthAccount) {
        self.grantee = signer.address
        self.counter = 0
        self.categories = {}
        // initial categories
        self.addCategory(signer, name: "Digital")
        self.addCategory(signer, name: "Physical")

        self.addCategory(signer, name: "Art")
        self.addCategory(signer, name: "Audio")
        self.addCategory(signer, name: "Video")
        self.addCategory(signer, name: "Photography")
        self.addCategory(signer, name: "Virtual Reality")
        self.addCategory(signer, name: "Augmented Reality")

        self.addCategory(signer, name: "Sculpture")
        self.addCategory(signer, name: "Fashion")
    }
}