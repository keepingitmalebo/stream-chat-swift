//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageListView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.utils) var utils
    
    var factory: Factory
    @Binding var messages: LazyCachedMapCollection<ChatMessage>
    @Binding var messagesGroupingInfo: [String: [String]]
    @Binding var scrolledId: String?
    @Binding var showScrollToLatestButton: Bool
    @Binding var currentDateString: String?
    
    var onMessageAppear: (Int) -> Void
    var onScrollToBottom: () -> Void
    
    @State private var width: CGFloat?
    @State private var height: CGFloat?
    @State private var keyboardShown = false
    
    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    private let scrollAreaId = "scrollArea"
    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    GeometryReader { proxy in
                        let frame = proxy.frame(in: .named(scrollAreaId))
                        let offset = frame.minY
                        let width = frame.width
                        let height = frame.height
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        Color.clear.preference(key: WidthPreferenceKey.self, value: width)
                        Color.clear.preference(key: HeightPreferenceKey.self, value: height)
                    }
                    
                    LazyVStack {
                        ForEach(messages.indices, id: \.self) { index in
                            let message = messages[index]
                            MessageView(
                                factory: factory,
                                message: message,
                                width: width,
                                showsAllInfo: showsAllData(for: message),
                                onLongPress: { _ in
                                    // viewModel.addReaction(to: viewModel.messages[index])
                                }
                            )
                            .padding(.horizontal)
                            .flippedUpsideDown()
                            .onAppear {
                                onMessageAppear(index)
                            }
                            .id(message.id)
                        }
                    }
                }
                .coordinateSpace(name: scrollAreaId)
                .onPreferenceChange(WidthPreferenceKey.self) { value in
                    if let value = value, value != width {
                        self.width = value
                    }
                }
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    showScrollToLatestButton = value ?? 0 < -20
                }
                .onPreferenceChange(HeightPreferenceKey.self) { value in
                    if let value = value, value != height {
                        self.height = value
                    }
                }
                .flippedUpsideDown()
                .frame(minWidth: self.width, minHeight: height)
                .onChange(of: scrolledId) { scrolledId in
                    if let scrolledId = scrolledId {
                        self.scrolledId = nil
                        withAnimation {
                            scrollView.scrollTo(scrolledId, anchor: .bottom)
                        }
                    }
                }
            }
            
//            if !viewModel.typingUsers.isEmpty {
//                VStack {
//                    Spacer()
//                    HStack {
//                        Text("\(viewModel.typingUsers[0]) is typing...")
//                            .padding(.horizontal)
//                            .padding(.vertical, 2)
//                        Spacer()
//                    }
//                    .background(Color.white.opacity(0.9))
//                }
//            }
//
            if showScrollToLatestButton {
                ScrollToBottomButton(onScrollToBottom: onScrollToBottom)
            }
            
            if let date = currentDateString {
                DateIndicatorView(date: date)
            }
        }
        .onReceive(keyboardPublisher) { visible in
            keyboardShown = visible
        }
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
    }
    
    private func showsAllData(for message: ChatMessage) -> Bool {
        let dateString = dateFormatter.string(from: message.createdAt)
        let prefix = message.isSentByCurrentUser ? "current" : "other"
        let key = "\(prefix)-\(dateString)"
        let inMessagingGroup = messagesGroupingInfo[key]?.contains(message.id) ?? false
        return inMessagingGroup
    }
}

public struct ScrollToBottomButton: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    private let buttonSize: CGFloat = 40
    
    var onScrollToBottom: () -> Void
    
    public var body: some View {
        BottomRightView {
            Button {
                onScrollToBottom()
            } label: {
                Image(uiImage: images.scrollDownArrow)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .modifier(ShadowViewModifier(cornerRadius: buttonSize / 2))
            }
            .padding()
        }
    }
}

public struct DateIndicatorView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var date: String
    
    public var body: some View {
        VStack {
            Text(date)
                .font(fonts.footnote)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .foregroundColor(.white)
                .background(Color(colors.textLowEmphasis))
                .cornerRadius(16)
                .padding(.all, 8)
            Spacer()
        }
    }
}