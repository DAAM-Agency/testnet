// remove_category.cdc
// Remove a new category to contract Category

import Categories from 0xa4ad5ea5c0bd2fba
import DAAM_V23       from 0xa4ad5ea5c0bd2fba

transaction(category: String) {
    let category: String
    let admin   : &DAAM_V23.Admin

    prepare(admin: AuthAccount) {
        self.category = category
<<<<<<< HEAD
        self.admin    = admin.borrow<&DAAM_V23.Admin>(from: DAAM_V23.adminStoragePath)!
=======
        self.admin    = admin.borrow<&DAAM.Admin>(from: DAAM_V23.adminStoragePath)!
>>>>>>> tomerge
    }

    pre { Categories.getCategories().contains(category) }

    execute {
        self.admin.removeCategory(name: self.category)
        log("Category: ".concat(self.category).concat(" removed."))
    }
}
