import SwiftUI

struct ClaimRestaurantView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.primary)
                
                Text("Claim \(restaurant.name)")
                    .font(.title2.weight(.bold))
                
                Text("Are you the owner of this restaurant? Claim it to manage menu items and respond to reviews.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button {
                    // Claim restaurant action
                    dismiss()
                } label: {
                    Text("Submit Claim Request")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
            .navigationTitle("Claim Restaurant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ClaimRestaurantView(restaurant: MockData.restaurants[0])
}
