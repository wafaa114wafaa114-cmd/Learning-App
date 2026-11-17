import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    // نستدعيها بعد الحفظ (ننتقل لشاشة Activity)
    var onStart: () -> Void = {}

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                Image(systemName: "flame.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.appOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                Text("Hello \(Text("Learner").fontWeight(.bold))")
                    .font(.system(size: 34))
                    .foregroundStyle(.white)
                    .padding(.top, 80)

                Text("This app will help you learn everyday!")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.appGray)
                    .padding(.top, 4)

                Text("I want to learn")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .padding(.top, 37)

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

                VStack(spacing: 12) {
                    Button {
                        viewModel.startLearning()
                        onStart()
                    } label: {
                        Text("Start Learning")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                    }
                    .glassButton()
                    .buttonBorderShape(.capsule)
                    .disabled(!viewModel.canStart)

                    Text("You can edit your desire later")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, -15)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    OnboardingView()
}
