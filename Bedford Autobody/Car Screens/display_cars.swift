import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DisplayCars: View {
    @Binding var cars: [Car]
    @Binding var selectedCar: Car?
    @State private var showingAddCarView = false
    @State private var carOffsetY: CGFloat = 0 // Vertical offset for bounce animation

    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Cars")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                if cars.isEmpty {
                    VStack {
                        Text("You haven't added any cars yet.")
                            .padding()

                        ZStack {
                            Image(systemName: "car.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 50)
                                .foregroundColor(.blue)
                                .offset(y: carOffsetY)
                                .onAppear {
                                    startBounceAnimation()
                                }
                        }
                        .frame(height: 100)
                    }
                } else {
                    List {
                        ForEach(cars) { car in
                            HStack {
                                Button(action: {
                                    selectedCar = car
                                    saveCar(car)
                                }) {
                                    HStack {
                                        Text("\(car.year) \(car.make) \(car.model)")
                                            .padding(.leading)
                                        Spacer()
                                        if selectedCar?.id == car.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteCar)
                    }
                }
                
                Button(action: {
                    showingAddCarView.toggle()
                }) {
                    Text("Add a New Car")
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showingAddCarView, onDismiss: {
                    loadCars()
                }) {
                    AddCarView(cars: $cars)
                }
            }
            .navigationTitle("Your Cars")
            .padding()
            .onAppear {
                loadCars()
            }
        }
    }

    func startBounceAnimation() {
        withAnimation(
            Animation
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            carOffsetY = -20
        }
    }
    
    func saveCar(_ car: Car) {
        guard let carId = car.id else { return }
        saveSelectedCar(carId: carId) { success in
            if success {
                print("Selected car updated.")
            }
        }
    }
    
    func loadCars() {
        fetchCars { fetchedCars, fetchedSelectedCar in
            self.cars = fetchedCars
            self.selectedCar = fetchedSelectedCar
        }
    }

    func deleteCar(at offsets: IndexSet) {
        for index in offsets {
            let car = cars[index]
            guard let carId = car.id else { continue }

            deleteSelectedCar(carId: carId) { success in
                if success {
                    cars.remove(at: index)
                    if selectedCar?.id == carId {
                        selectedCar = nil
                    }
                }
            }
        }
    }
}
