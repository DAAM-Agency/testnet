pub contract Categories {
    // events
    pub event CategoryAdded(name: String, id: UInt64)
    pub event CategoryRemoved(name: String, id: UInt64)

    //struct
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
    priv var counter   : UInt64            // A counter used as an incremental Category ID
    access(contract) var categories: {String : UInt64} // category list { category name : categoty counter (acts as ID)}

    // functions
    // Validate category entries are valid.
    priv fun validate(list: [UInt64]) {
        for l in list {
            self.categories.contains
        }
    }

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

    pub fun assignCategoryByName(_ name: String): Category {
        pre { self.categories.containsKey(name) : "Invalid Category" }
        return Category(self.categories[name]!.ids)
    }
    
    pub fun addCategory(name: String) {
        pre { !self.categories.containsKey(name) : "Category: ".concat(name).concat(" already exists.") }
        post{ self.categories.containsKey(name) : "Internal Error: Add Category" }

        self.categories.insert(key: name, self.counter)
        self.counter = self.counter + 1
        emit CategoryAdded(name: name, id: self.counter)
    }

    pub fun removeCategory(name: String) {
        pre { self.categories.containsKey(name) : "Category: ".concat(name).concat(" does not exists.") }
        post{ !self.categories.containsKey(name) : "Internal Error: Remove Category" }

        self.categories.remove(key: name)
        emit CategoryRemoved(name: name, id: self.counter)
    }

    init() {
        self.counter = 0
        self.categories = {}
    }
}