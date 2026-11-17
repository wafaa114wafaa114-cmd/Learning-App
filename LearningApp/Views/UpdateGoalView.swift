import SwiftUI

struct UpdateGoalView: View {
    @State private var viewModel = UpdateGoalViewModel()

    var onUpdated: () -> Void = {}
    var onBack: () -> Void = {}

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                ZStack {
                    Text("Learning Goal")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)

                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 28, height: 28)
                        }
                        .glassButton(selected: false)
                        .buttonBorderShape(.circle)

                        Spacer()

                        Button {
                            viewModel.submit()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(width: 28, height: 28)
                        }
                        .glassButton()
                        .buttonBorderShape(.circle)
                        .disabled(!viewModel.canSubmit)
                    }
                }

                Text("I want to learn")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.top, 40)

                TextField("", text: $viewModel.goal, prompt: Text("Swift").foregroundStyle(Color(red: 0.3, green: 0.3, blue: 0.3)))
                    .font(.system(size: 17))
                    .foregroundStyle(.white)
                    .frame(height: 48)
                    .padding(.top, 5)

                Rectangle()
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .frame(height: 1)

                Text("I want to learn it in a")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.top, 30)

                HStack(spacing: 16) {
                    ForEach(Duration.allCases, id: \.self) { duration in
                        Button {
                            viewModel.select(duration)
                        } label: {
                            Text(duration.rawValue)
                                .font(.system(size: 17, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .glassButton(selected: viewModel.selectedDuration == duration)
                        .buttonBorderShape(.capsule)
                    }
                }
                .padding(.top, 12)

                Spacer()
            }
            .padding(.horizontal, 16)

            // التنبيه المخصص: خلفية معتمة + بطاقة داكنة + زرين
            if viewModel.showAlert {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.showAlert = false }

                alertCard
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.showAlert)
    }

    // بطاقة التنبيه: نفس تصميم Sketch (Dismiss رمادي داكن، Update برتقالي)
    private var alertCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Update goal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            Text("If you update now, your streak will start over.")
                .font(.system(size: 15))
                .foregroundStyle(Color.appGray)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button {
                    viewModel.showAlert = false
                } label: {
                    Text("Dismiss")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .glassButton(selected: false)
                .buttonBorderShape(.capsule)

                Button {
                    viewModel.confirmUpdate()
                    viewModel.showAlert = false
                    onUpdated()
                } label: {
                    Text("Update")
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .glassButton()
                .buttonBorderShape(.capsule)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        )
        .frame(maxWidth: 300)
    }
}

#Preview {
    UpdateGoalView()
}
