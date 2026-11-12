import SwiftUI

struct ContentView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                Image(systemName: "flame.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color(red: 1.0, green: 0.57, blue: 0.19))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)

                Text("Hello \(Text("Learner").fontWeight(.bold))")
                    .font(.system(size: 34))
                    .foregroundStyle(.white)
                    .padding(.top, 80)

                Text("This app will help you learn everyday!")
                    .font(.system(size: 17))
                    .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6))
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
                                .foregroundStyle(viewModel.selectedDuration == duration ? .white : Color(red: 0.6, green: 0.6, blue: 0.6))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(viewModel.selectedDuration == duration ? Color(red: 1.0, green: 0.57, blue: 0.19) : Color(red: 0.15, green: 0.15, blue: 0.15))
                                )
                        }
                    }
                }
                .padding(.top, 12)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        viewModel.startLearning()
                    } label: {
                        Text("Start Learning")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color(red: 1.0, green: 0.57, blue: 0.19))
                            )
                    }

                    Text("You can edit your desire later")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, -15)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    ContentView()
}
