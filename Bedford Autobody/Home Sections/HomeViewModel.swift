//
//  HomeViewModel.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 3/6/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var firstName: String = "User"
    @Published var lastName: String = ""
    @Published var cars: [Car] = []
    @Published var selectedCar: Car? = nil

    init() {
        fetchUserName()
        fetchCars()
    }

    private func fetchUserName() {
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("users").document(user.uid)
            .addSnapshotListener { document, error in
                if let data = document?.data(), let firstName = data["firstName"] as? String {
                    DispatchQueue.main.async {
                        self.firstName = firstName
                    }
                }
            }
    }

    private func fetchCars() {
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore().collection("users").document(user.uid).collection("cars")
            .addSnapshotListener { snapshot, error in
                let cars = snapshot?.documents.compactMap { try? $0.data(as: Car.self) } ?? []
                DispatchQueue.main.async {
                    self.cars = cars
                    self.selectedCar = cars.first // Default to first car
                }
            }
    }
}
