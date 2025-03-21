//
//  car_struct.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/6/25.
//

import Foundation
import FirebaseFirestore

struct Car: Identifiable, Decodable, Encodable, Equatable {
    @DocumentID var id: String?  // Firestore automatically sets this to the document ID
    var ownerId: String? // New property for the customer's user ID
    var make: String
    var model: String
    var submodel: String // 🔹 NEW: Store submodel
    var year: String
    var vin: String
    var color: String
    var numDoors: Int // 🔹 NEW: Store number of doors (2 or 4)
    var carType: String // 🔹 NEW: Store type of car (SUV, Truck, Sedan, etc.)
    var repairStates: [String] // Repair states array
    var currentRepairState: String // Current repair state
    var estimateTotal: Double? // Holds the total estimate amount
    var estimatedPickupDate: String? // Stores the pickup date

    init(
        id: String? = nil,
        ownerId: String? = nil, // New parameter
        make: String,
        model: String,
        submodel: String = "", // 🔹 Default empty string
        year: String,
        vin: String,
        color: String,
        numDoors: Int = 4, // 🔹 Default to 4 doors
        carType: String = "Sedan", // 🔹 Default to Sedan
        repairStates: [String] = ["Estimate Updates", "Parts Ordered", "Repair in Progress", "Painting", "Final Inspection", "Ready for pickup"],
        currentRepairState: String = "Estimate Updates",
        estimateTotal: Double? = nil, // Initialize with nil
        estimatedPickupDate: String? = nil // Default to nil
    ) {
        self.id = id
        self.ownerId = ownerId // Initialize ownerId
        self.make = make
        self.model = model
        self.submodel = submodel
        self.year = year
        self.vin = vin
        self.color = color
        self.numDoors = numDoors
        self.carType = carType
        self.repairStates = repairStates
        self.currentRepairState = currentRepairState
        self.estimateTotal = estimateTotal
        self.estimatedPickupDate = estimatedPickupDate
    }
}
