import Foundation
import FirebaseFirestore

struct Car: Identifiable, Decodable {
    @DocumentID var id: String?  // Firestore automatically sets this to the document ID
    var make: String
    var model: String
    var year: String
    var vin: String
    var color: String

    // Default initializer is automatically provided for simple structs, but you can also create a custom initializer if needed.
    init(make: String, model: String, year: String, vin: String, color: String) {
        self.make = make
        self.model = model
        self.year = year
        self.vin = vin
        self.color = color
    }
}
