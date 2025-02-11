//
//  car_struct.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/6/25.
//

import Foundation
import FirebaseFirestore

struct Car: Identifiable, Decodable, Encodable {
    @DocumentID var id: String?  // Firestore automatically sets this to the document ID
    var ownerId: String? // New property for the customer's user ID
    var make: String
    var model: String
    var year: String
    var vin: String
    var color: String
    var repairStates: [String] // Repair states array
    var currentRepairState: String // Current repair state
    var estimateTotal: Double? // Holds the total estimate amount
    var estimatedPickupDate: String? // 🔹 NEW FIELD - Stores the pickup date

    init(
        id: String? = nil,
        ownerId: String? = nil, // New parameter
        make: String,
        model: String,
        year: String,
        vin: String,
        color: String,
        repairStates: [String] = ["Estimate Updates", "Parts Ordered", "Repair in Progress", "Painting", "Final Inspection", "Ready for pickup"],
        currentRepairState: String = "Estimate Updates",
        estimateTotal: Double? = nil, // Initialize with nil
        estimatedPickupDate: String? = nil // 🔹 NEW: Default to nil
    ) {
        self.id = id
        self.ownerId = ownerId // Initialize ownerId
        self.make = make
        self.model = model
        self.year = year
        self.vin = vin
        self.color = color
        self.repairStates = repairStates
        self.currentRepairState = currentRepairState
        self.estimateTotal = estimateTotal // Set initial value for estimate total
        self.estimatedPickupDate = estimatedPickupDate // Set initial value for estimated pickup date
    }
}
