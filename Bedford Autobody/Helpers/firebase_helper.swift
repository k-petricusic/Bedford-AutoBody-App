//
//  firebase_helper.swift
//  Bedford Autobody
//
//  Created by Kris at Bedford Autobody on 2/7/25.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

func fetchUserName(completion: @escaping (String, String) -> Void) {
    guard let user = Auth.auth().currentUser else {
        completion("User", "")
        return
    }
    let db = Firestore.firestore()
    db.collection("users").document(user.uid).getDocument { document, error in
        if let error = error {
            print("Error fetching user data: \(error.localizedDescription)")
            completion("User", "")
        } else if let document = document, document.exists {
            let data = document.data()
            let firstName = data?["firstName"] as? String ?? "User"
            let lastName = data?["lastName"] as? String ?? ""
            completion(firstName, lastName)
        } else {
            completion("User", "")
        }
    }
}

func checkAdminStatus(completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
        completion(false)
        return
    }
    let isAdmin = (user.email?.lowercased() == "K@gmail.com".lowercased())
    completion(isAdmin)
}

func fetchCars(completion: @escaping ([Car], Car?) -> Void) {
    guard let user = Auth.auth().currentUser else {
        completion([], nil)
        return
    }
    
    let db = Firestore.firestore()
    db.collection("users").document(user.uid).collection("cars")
        .getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching cars: \(error.localizedDescription)")
                completion([], nil)
            } else {
                let cars = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Car.self)
                } ?? []
                
                db.collection("users").document(user.uid).getDocument { document, error in
                    if let error = error {
                        print("Error fetching last selected car ID: \(error.localizedDescription)")
                        completion(cars, nil)
                    } else if let document = document, document.exists,
                              let lastSelectedCarId = document.data()?["lastSelectedCarId"] as? String,
                              let selectedCar = cars.first(where: { $0.id == lastSelectedCarId }) {
                        completion(cars, selectedCar)
                    } else {
                        completion(cars, nil)
                    }
                }
            }
        }
}

func checkUnreadNotifications(completion: @escaping (Int) -> Void) {
    let db = Firestore.firestore()
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(0)
        return
    }

    db.collection("users").document(userId).collection("notifications")
        .whereField("isRead", isEqualTo: false)
        .getDocuments { snapshot, error in
            if let error = error {
                print("Error checking unread notifications: \(error.localizedDescription)")
                completion(0)
            } else {
                completion(snapshot?.documents.count ?? 0)
            }
        }
}

func handleLogout(completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
        completion(false)
        return
    }
    let db = Firestore.firestore()

    db.collection("users").document(user.uid).updateData([
        "fcmToken": FieldValue.delete()
    ]) { error in
        if let error = error {
            print("Error removing FCM token: \(error.localizedDescription)")
        } else {
            print("FCM token removed successfully for user \(user.uid)")
        }

        do {
            try Auth.auth().signOut()
            completion(true)
        } catch let signOutError {
            print("Error signing out: \(signOutError.localizedDescription)")
            completion(false)
        }
    }
}

func fetchPDFURL(forCarId carId: String, ownerId: String, completion: @escaping (String?) -> Void) {
    let db = Firestore.firestore()
    db.collection("users")
        .document(ownerId)
        .collection("cars")
        .document(carId)
        .collection("pdfs")
        .order(by: "timestamp", descending: true)
        .limit(to: 1)
        .getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching PDF URL: \(error.localizedDescription)")
                completion(nil)
            } else if let document = snapshot?.documents.first, let url = document.data()["url"] as? String {
                completion(url)
            } else {
                print("No PDFs found.")
                completion(nil)
            }
        }
}

func fetchOngoingRepairs(completion: @escaping ([Car], String?) -> Void) {
    let db = Firestore.firestore()

    db.collection("users").getDocuments { snapshot, error in
        if let error = error {
            print("Error fetching users: \(error.localizedDescription)")
            completion([], "Failed to fetch users.")
            return
        }

        guard let userDocuments = snapshot?.documents else {
            completion([], "No users found.")
            return
        }

        let group = DispatchGroup()
        var fetchedCars: [Car] = []

        for userDocument in userDocuments {
            group.enter()
            db.collection("users")
                .document(userDocument.documentID)
                .collection("cars")
                .whereField("currentRepairState", isNotEqualTo: "Ready for pickup") // Exclude "Ready for pickup" cars
                .getDocuments { carSnapshot, carError in
                    if let carError = carError {
                        print("Error fetching cars: \(carError.localizedDescription)")
                    } else if let carDocuments = carSnapshot?.documents {
                        fetchedCars += carDocuments.compactMap { try? $0.data(as: Car.self) }
                    }
                    group.leave()
                }
        }

        group.notify(queue: .main) {
            completion(fetchedCars, nil)
        }
    }
}

func fetchCarImages(carId: String, completion: @escaping ([String], String?) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion([], "User not logged in.")
        return
    }

    let db = Firestore.firestore()
    db.collection("users")
        .document(userId)
        .collection("cars")
        .document(carId)
        .collection("images")
        .getDocuments { snapshot, error in
            if let error = error {
                completion([], error.localizedDescription)
                return
            }

            guard let documents = snapshot?.documents else {
                completion([], "No images found for this car.")
                return
            }

            let images = documents.compactMap { $0.data()["url"] as? String }
            completion(images, nil)
        }
}

func saveSelectedCar(carId: String, completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
        completion(false)
        return
    }

    let db = Firestore.firestore()
    db.collection("users").document(user.uid).updateData([
        "lastSelectedCarId": carId
    ]) { error in
        if let error = error {
            print("Error saving selected car ID: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Selected car ID saved successfully!")
            completion(true)
        }
    }
}

func deleteSelectedCar(carId: String, completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
        completion(false)
        return
    }

    let db = Firestore.firestore()
    db.collection("users").document(user.uid).collection("cars").document(carId).delete { error in
        if let error = error {
            print("Error deleting car: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Car deleted successfully!")
            completion(true)
        }
    }
}

func fetchNotifications(completion: @escaping ([Notification], String?) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion([], "User not logged in.")
        return
    }

    let db = Firestore.firestore()
    db.collection("users").document(userId).collection("notifications")
        .order(by: "date", descending: true)
        .getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching notifications: \(error.localizedDescription)")
                completion([], "Failed to fetch notifications.")
            } else {
                let notifications = snapshot?.documents.compactMap { document in
                    try? document.data(as: Notification.self)
                } ?? []
                completion(notifications, nil)
            }
        }
}

func markNotificationAsRead(notificationId: String, completion: @escaping (Bool) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(false)
        return
    }

    let db = Firestore.firestore()
    db.collection("users").document(userId).collection("notifications").document(notificationId)
        .updateData(["isRead": true]) { error in
            if let error = error {
                print("Error marking notification as read: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
}

func deleteNotification(notificationId: String, completion: @escaping (Bool) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(false)
        return
    }

    let db = Firestore.firestore()
    db.collection("users").document(userId).collection("notifications").document(notificationId)
        .delete { error in
            if let error = error {
                print("Error deleting notification: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
}

// Function to add a new car to Firestore
func addCarToFirestore(car: Car, userId: String) {
    let db = Firestore.firestore()
    let carRef = db.collection("users")
        .document(userId)
        .collection("cars")
        .document()

    do {
        try carRef.setData(from: car) { error in
            if let error = error {
                print("Error adding car to Firestore: \(error.localizedDescription)")
            } else {
                print("Car added successfully!")
            }
        }
    } catch {
        print("Error encoding car data: \(error.localizedDescription)")
    }
}

// Function to fetch estimated pickup date for a car
func fetchEstimatedPickupDate(userId: String, carId: String, completion: @escaping (String?) -> Void) {
    let db = Firestore.firestore()
    let carRef = db.collection("users")
        .document(userId)
        .collection("cars")
        .document(carId)

    carRef.getDocument { document, error in
        if let error = error {
            print("Error fetching estimated pickup date: \(error.localizedDescription)")
            completion(nil)
        } else if let document = document, document.exists {
            let data = document.data()
            let pickupDate = data?["estimatedPickupDate"] as? String
            completion(pickupDate)
        } else {
            completion(nil)
        }
    }
}

// Function to update estimated pickup date
func updateEstimatedPickupDate(userId: String, carId: String, newDate: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let carRef = db.collection("users")
        .document(userId)
        .collection("cars")
        .document(carId)

    carRef.updateData(["estimatedPickupDate": newDate]) { error in
        if let error = error {
            print("Error updating pickup date: \(error.localizedDescription)")
            completion(false)
        } else {
            print("Pickup date updated successfully!")
            completion(true)
        }
    }
}

func saveProfile(fullName: String, email: String, phone: String, completion: @escaping (Bool, String?) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(false, "User not authenticated.")
        return
    }

    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userId)

    // 🔹 Split fullName into first and last name
    let nameComponents = fullName.split(separator: " ")
    let firstName = nameComponents.first ?? ""
    let lastName = nameComponents.dropFirst().joined(separator: " ")

    let updatedData: [String: Any] = [
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone
    ]

    userRef.updateData(updatedData) { error in
        if let error = error {
            print("Error updating profile: \(error.localizedDescription)")
            completion(false, error.localizedDescription)
        } else {
            print("Profile updated successfully!")
            completion(true, nil)
        }
    }
}

func uploadProfilePicture(image: UIImage, completion: @escaping (String?) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(nil)
        return
    }
    
    let storageRef = Storage.storage().reference().child("profile_pictures/\(userId).jpg")
    
    guard let imageData = image.jpegData(compressionQuality: 0.4) else {
        completion(nil)
        return
    }
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    storageRef.putData(imageData, metadata: metadata) { _, error in
        if let error = error {
            print("Error uploading profile picture: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        storageRef.downloadURL { url, error in
            if let error = error {
                print("Error getting download URL: \(error.localizedDescription)")
                completion(nil)
            } else if let url = url {
                saveProfilePictureURL(url: url.absoluteString)
                completion(url.absoluteString)
            }
        }
    }
}

func saveProfilePictureURL(url: String) {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    
    let db = Firestore.firestore()
    db.collection("users").document(userId).updateData([
        "profilePictureURL": url
    ]) { error in
        if let error = error {
            print("Error saving profile picture URL: \(error.localizedDescription)")
        } else {
            print("Profile picture URL updated successfully.")
        }
    }
}

func fetchProfilePictureURL(completion: @escaping (String?) -> Void) {
    guard let userId = Auth.auth().currentUser?.uid else {
        completion(nil)
        return
    }
    
    let db = Firestore.firestore()
    db.collection("users").document(userId).getDocument { document, error in
        if let error = error {
            print("Error fetching profile picture URL: \(error.localizedDescription)")
            completion(nil)
        } else if let data = document?.data(), let url = data["profilePictureURL"] as? String {
            completion(url)
        } else {
            completion(nil)
        }
    }
}
