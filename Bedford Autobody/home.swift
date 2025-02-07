import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import ConfettiSwiftUI

struct HomeScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var email: String
    @State private var firstName: String? = nil
    @State private var lastName: String? = nil
    @State private var isLoggedOut = false
    @State private var cars: [Car] = []
    @State private var selectedCar: Car? = nil
    @State private var showCarSelection = false
    @State private var showChatView = false
    @State private var showAdminMenu = false
    @State private var isAdmin = false
    @State private var showImages = false // New state for the Images screen
    @State private var animatedProgress: Double = 0.0 // For animating the progress
    @State private var carOffsetY: CGFloat = 0.0 // For the hop animation
    @State private var isHopping = false // To control the hop animation
    @State private var confettiCounter = 0 // For triggering the confetti
    @State private var hasUnreadNotifications = false // Tracks unread notifications
    @State private var unreadNotifications = 0 // New state for notification count
    @State private var selectedPDFURL: URL? = nil
    @State private var showPDFViewer = false
    @State private var selectedTab = 0 // Track the tab selection


    let adminEmail = "K@gmail.com"

    func animateProgress() {
        animatedProgress = 0.0 // Start from the beginning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Add a small delay before animating
            if let repairStates = selectedCar?.repairStates,
               let currentRepairState = selectedCar?.currentRepairState,
               let currentIndex = repairStates.firstIndex(of: currentRepairState) {
                let progress = Double(currentIndex) / Double(repairStates.count - 1)
                withAnimation(.easeOut(duration: 2.0)) { // Smooth animation
                    animatedProgress = progress
                }

                // Perform hop animation after progress bar animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    performCarHop()
                }

                // Trigger confetti if car reaches the final state
                if currentRepairState == "Ready for pickup" {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        confettiCounter += 1
                    }
                }
            }
        }
    }

    func performCarHop() {
        guard !isHopping else { return } // Prevent multiple hops
        isHopping = true

        // First hop up
        withAnimation(.easeOut(duration: 0.3)) {
            carOffsetY = -20 // Move the car icon up
        }

        // Move back down with a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                carOffsetY = 0 // Bring the car icon back down
            }
            isHopping = false
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    WelcomeMessage(firstName: firstName, lastName: lastName, colorScheme: colorScheme)
                    if selectedCar == nil {
                        VStack {
                            Text("Please select a car")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .padding()
                            
                            Button(action: {
                                showCarSelection = true
                            }) {
                                Text("Select Car")
                                    .font(.headline)
                                    .padding()
                                    .frame(minWidth: 200)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.top, 20)
                        }
                        .padding()
                    } else {
                        CarDetailsView(selectedCar: selectedCar)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.top, 20)
                    }
                    
                    // New Placeholder Section
                    JobEstimateSection(
                        selectedCar: selectedCar,
                        selectedPDFURL: $selectedPDFURL,
                        showPDFViewer: $showPDFViewer
                    )
                    
                    RepairProgressView(
                        selectedCar: selectedCar,
                        animatedProgress: $animatedProgress,
                        carOffsetY: $carOffsetY,
                        confettiCounter: $confettiCounter
                    )
                    
                    Button(action: {
                        showChatView = true
                    }) {
                        Text("Go to Chat")
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 200)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    
                    if isAdmin {
                        Button(action: {
                            showAdminMenu = true
                        }) {
                            Text("Admin Menu")
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 200)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    
                    Button(action: {
                        handleLogout { success in
                            if success {
                                isLoggedOut = true
                            }
                        }
                    }) {
                        Text("Logout")
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 200)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .background(colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(10)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                fetchUserName { firstName, lastName in
                    self.firstName = firstName
                    self.lastName = lastName
                }
                
                fetchCars { cars, selectedCar in
                    self.cars = cars
                    self.selectedCar = selectedCar
                    if selectedCar != nil {
                        animateProgress()
                    }
                }
                
                checkAdminStatus { isAdmin in
                    self.isAdmin = isAdmin
                }
                
                checkUnreadNotifications { count in
                    self.unreadNotifications = count
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    // Notification Icon in Top Left
                    NavigationLink(destination: NotificationsScreen()) {
                        ZStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            
                            if unreadNotifications > 0 {
                                Text("\(unreadNotifications)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Circle().fill(Color.red))
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Top Right Toolbar Menu
                    Menu {
                        NavigationLink(destination: DisplayCars(cars: $cars, selectedCar: $selectedCar)) {
                            Label("Your Cars", systemImage: "car.fill")
                        }
                        
                        NavigationLink(destination: ImagesScreen(carId: selectedCar?.id ?? "")) {
                            Label("Images", systemImage: "photo.artframe")
                        }
                        
                        NavigationLink(destination: FAQScreen()) {
                            Label("FAQ", systemImage: "questionmark.circle")
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
            }
            
            NavigationLink(destination: LoginOptions(), isActive: $isLoggedOut) {
                EmptyView()
            }
            
            NavigationLink(destination: DisplayCars(cars: $cars, selectedCar: $selectedCar), isActive: $showCarSelection) {
                EmptyView()
            }
            
            NavigationLink(
                destination: ChatViewWrapper()
                    .navigationTitle("Bedford Autobody"),
                isActive: $showChatView
            ) {
                EmptyView()
            }
            
            NavigationLink(destination: AdminMenu(), isActive: $showAdminMenu) {
                EmptyView()
            }
            
            NavigationLink(
                destination: selectedPDFURL.map { PDFViewer(pdfURL: $0) },
                isActive: $showPDFViewer
            ) {
                EmptyView()
            }
        }
        BottomMenuView(selectedTab: $selectedTab)
            .background(Color.white) // Ensures it's visible properly
            .edgesIgnoringSafeArea(.bottom)
    }
}

// Wrapper for ChatView (UIKit in SwiftUI)
struct ChatViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ChatView {
        return ChatView()
    }

    func updateUIViewController(_ uiViewController: ChatView, context: Context) {}
}
