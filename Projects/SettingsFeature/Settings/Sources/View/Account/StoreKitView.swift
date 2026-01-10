//
//  StoreKitView.swift
//  Settings
//
//  Created by 박현수 on 1/14/25.
//

import SwiftUI
import CommonUI

struct StoreKitView: View {

    @StateObject var viewModel: StoreKitViewModel
    var diContainer: any SettingsDependencyInjection

    @Environment(\.dismiss) var dismiss

    @State var successPurchaseAlert: Bool = false
    @State var failedPurchaseAlert: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false

    init(diContainer: any SettingsDependencyInjection) {
        self.diContainer = diContainer
        _viewModel = StateObject(wrappedValue: StoreKitViewModel(
            accountService: diContainer.makeAccountImplementation(),
            storeKitService: diContainer.storeKitServiceImplementation()
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 헤더
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.systemBlack.opacity(0.8), Color.systemBlack],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "crown.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.systemWhite)
                    }

                    Text("AI 학습 구매권")
                        .font(.title.bold())
                        .foregroundStyle(Color.primary)

                    Text("더 많은 AI 기능을 사용해보세요")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                }
                .padding(.top, 20)

                // 혜택 카드
                VStack(spacing: 0) {
                    // AI 문장 생성
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.systemBlack.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image("ph_open-ai-logo-light", bundle: CommonUIResources.bundle)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("AI 문장 생성 기능")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.primary)
                            Text("200회 추가 제공")
                                .font(.headline)
                                .foregroundStyle(Color.systemBlack)
                        }

                        Spacer()

                        Text("+200")
                            .font(.title3.bold())
                            .foregroundStyle(Color.systemBlack)
                    }
                    .padding(16)

                    Divider()
                        .padding(.horizontal, 16)

                    // AI 스피킹
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.systemBlack.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: "waveform")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color.systemBlack)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("AI 스피킹 기능")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.primary)
                            Text("100회 추가 제공")
                                .font(.headline)
                                .foregroundStyle(Color.systemBlack)
                        }

                        Spacer()

                        Text("+100")
                            .font(.title3.bold())
                            .foregroundStyle(Color.systemBlack)
                    }
                    .padding(16)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Spacer(minLength: 40)

                // 구매 버튼
                Button {
                    Task {
                        do {
                            isLoading = true
                            try await viewModel.purchaseFirst()
                            successPurchaseAlert = true
                        } catch {
                            failedPurchaseAlert = true
                            errorMessage = error.localizedDescription
                        }
                        isLoading = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isLoading {
                            ProgressView()
                                .tint(Color.systemWhite)
                        } else {
                            Text("₩1,100")
                                .font(.headline)
                            Text("구매하기")
                                .font(.headline)
                        }
                    }
                    .foregroundStyle(Color.systemWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.systemBlack)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(isLoading)

                // 안내 문구
                Text("구매 후 즉시 적용됩니다")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("구매")
        .navigationBarTitleDisplayMode(.inline)
        .alert("구매 완료", isPresented: $successPurchaseAlert) {
            Button("확인") {
                dismiss()
            }
        } message: {
            Text("AI 기능이 충전되었습니다!")
        }
        .alert(LocalizedStringKey(errorMessage),
               isPresented: $failedPurchaseAlert,
               presenting: errorMessage) { _ in
            Button("확인", role: .cancel) {}
        } message: { _ in }
    }
}

#Preview {
    NavigationStack {
        StoreKitView(diContainer: SettingsMockDIContainer())
    }
}
