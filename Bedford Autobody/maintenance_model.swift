import Foundation

struct MaintenanceLog: Identifiable, Codable {
    var id: String?
    var carId: String
    var type: String
    var date: Date
    
    init(id: String? = nil, carId: String, type: String, date: Date) {
        self.id = id
        self.carId = carId
        self.type = type
        self.date = date
    }
}

