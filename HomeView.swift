//
//  SwiftUIView.swift
//  
//
//  Created by Nantanat Thongthep on 19/4/2566 BE.
//

import SwiftUI
import AVFoundation

struct Home: View {
    
    //MARK: - Puzzle
    @State var currentPuzzle: Puzzle = puzzles[0]
    @State var selectedLetters: [Letter] = []
    @State var rows: [[Letter]] = []
    @State var index = 0
    
    //MARK: - Progress Bar
    @State var progressBar: CGFloat = 0
    @State var droppedCount: CGFloat = 0
    
    //MARK: - Input Field's Label
    @State var isCorrect: Bool = false
    @State var notiLabel: String = ""
    
    //MARK: - Image Card
    @State var offset: CGSize = .zero
    var screenSize: CGSize = {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return window.screen.bounds.size
    }()
    
    //MARK: - Text Speech
    @State var utterance: AVSpeechUtterance!
    @State var synthesizer = AVSpeechSynthesizer()
    @State var speaking = false
    
    //MARK: - Change View
    @State var isShowingSecondView = false
                    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack (spacing: 0) {
                    NavBar()
                    
                    ImageCard(geometry)
                    
                    VStack {
                        Text(notiLabel)
                            .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.045))
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(notiLabel == "Dump your trash here!" ? .black : .red)
                        
                        InputField(geometry)

                        EmojiChoice(geometry)
                    }
                    .padding(.vertical, geometry.size.height * 0.02)
                    
                    ButtonDone(geometry)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .onAppear {
                    generateLetters()
                    rows = generateGrid()
                    updateLabel()
                }
            }
        }
    }
    
    
    //MARK: - UI
    @ViewBuilder
    func NavBar() -> some View {
        HStack (spacing: 18) {
            Button {
                
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            GeometryReader { proxy in
                ZStack (alignment: .leading) {
                    Capsule()
                        .fill(.gray.opacity(0.25))
                    
                    Capsule()
                        .fill(Color.green)
                        .frame(width: proxy.size.width * progressBar)
                }
            }
            .frame(height: 20)
            
            Button {
                
            } label: {
                Image(systemName: "flag.checkered")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
    }
    
    @ViewBuilder
    func ImageCard(_ geometry: GeometryProxy) -> some View {
        VStack (alignment: .leading) {
            Text("MOVE ME!")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundColor(.gray)
                        
            Image(currentPuzzle.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .offset(x: offset2Angle().degrees * 5, y: offset2Angle(true).degrees * 5)
                .shadow(radius: 20)

            VStack (alignment: .leading, spacing: 10) {
                HStack (spacing: 8) {
                    Text(currentPuzzle.title)
                        .font(.system(size: 18, weight: .bold))
                    
                    Button {
                        if self.synthesizer.isSpeaking {
                            self.synthesizer.stopSpeaking(at: .immediate)
                            self.speaking = false
                        } else {
                            speakText(text: currentPuzzle.title)
                            speakText(text: " ")
                            speakText(text: currentPuzzle.describe)
                            self.speaking = true
                        }
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.white)
                            .padding(4)
                            .background(.black.opacity(0.3))
                            .cornerRadius(6)
                    }
                }

                Text(currentPuzzle.describe)
                    .font(.system(size: 18))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background(
            ZStack (alignment: .topTrailing) {
                Rectangle()
                    .fill(currentPuzzle.color.opacity(0.2))
            }
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        )
        .rotation3DEffect(offset2Angle(true), axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(offset2Angle(), axis: (x: 0, y: 1, z: 0))
        .rotation3DEffect(offset2Angle(true), axis: (x: 0, y: 0, z: 1))
        .scaleEffect(0.9)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged({ value in
                    offset = value.translation
                }).onEnded({ _ in
                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.32, blendDuration: 0.32)) {
                        offset = .zero
                    }
                })
        )
        .padding(.top, geometry.size.height * 0.02)
        .frame(height: max(geometry.size.height * 0.5, 250))
    }

    @ViewBuilder
    func InputField(_ geometry: GeometryProxy) -> some View {
        
        HStack (spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue.opacity(0.2))
                        .frame(width: geometry.size.width / 8, height: geometry.size.width / 8)

                    if selectedLetters.count > index {
                        Text(selectedLetters[index].value)
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .center)
        .padding(.bottom, geometry.size.height * 0.04)
    }
    
    @ViewBuilder
    func EmojiChoice(_ geometry: GeometryProxy) -> some View {
        VStack (spacing: 12) {
            ForEach (rows, id: \.self) { row in
                HStack (spacing: 10) {
                    ForEach (row) { item in
                        HStack {
                            Text(item.value)
                                .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.045))
                                .foregroundColor(.black)
                                .padding(.vertical, geometry.size.width / 30)
                                .padding(.horizontal, geometry.size.width / 30)
                                .background {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(.gray)
                                }
                                .background {
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(isSelected(letter: item) ? .gray.opacity(0.25) : .clear)
                                }
                                .onTapGesture {
                                    addLetter(letter: item)
                                }
                        }
                    }
                }

                if rows.last != row {
                    Divider()
                }
            }
        }
    }
    
    @ViewBuilder
    func ButtonDone(_ geometry: GeometryProxy) -> some View {
        Button {
            guard isCorrect else {
                return updateLabel()
            }
            
            selectedLetters.removeAll()
            updateLabel()
            updateProgress()
            MusicPlayer.shared.playMusic(name: "correct-sound", type: "wav", loop: false, action: "sound effect")
            
            if self.synthesizer.isSpeaking {
                self.synthesizer.stopSpeaking(at: .immediate)
                self.speaking = false
            }
            
            guard index < puzzles.count - 1 else {
                return self.isShowingSecondView = true
            }
                        
            index += 1
            currentPuzzle = puzzles[index]
            
        } label: {
            Text("Done")
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.blue, in: RoundedRectangle(cornerRadius: 10))
        }
        .disabled(selectedLetters.count != currentPuzzle.answer.count)
        .opacity(selectedLetters.count != currentPuzzle.answer.count ? 0.6 : 1)
        .fullScreenCover(isPresented: $isShowingSecondView, content: {
            Congratulations()
        })
        .frame(maxWidth: .infinity)
        .padding(.top, geometry.size.height * 0.035)
    }
    
    
    //MARK: - Logic
    func speakText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        self.synthesizer.speak(utterance)
    }
    
    func offset2Angle(_ isVertical: Bool = false) -> Angle {
        let progress = (isVertical ? offset.height : offset.width) / (isVertical ? screenSize.height : screenSize.width)
        return .init(degrees: progress * 10)
    }
    
    func updateLabel() {
        guard selectedLetters.count == currentPuzzle.answer.count else {
            self.notiLabel = "Dump your trash here!"
            return
        }
        
        self.notiLabel = "Oops! You threw the trash in the wrong bin!"
    }
    
    func generateLetters() {
        currentPuzzle.choice.shuffled().forEach { character in
            currentPuzzle.letters.append(Letter(value: String(character)))
        }
    }
    
    func addLetter(letter: Letter) {
        withAnimation {
            if isSelected(letter: letter) {
                selectedLetters.removeAll { currentLetter in
                    return currentLetter.id == letter.id
                }
                isCorrect = false
                updateLabel()
            }
            else {
                if selectedLetters.count == currentPuzzle.answer.count { return }
                selectedLetters.append(letter)
                
                if selectedLetters.count == currentPuzzle.answer.count {
                    for i in 0..<selectedLetters.count {
                        isCorrect = currentPuzzle.answer.contains(selectedLetters[i].value)
                        if !isCorrect {
                            break
                        }
                    }
                }
            }
        }
    }
    
    func updateProgress() {
        droppedCount += 1
        let progress = (droppedCount / CGFloat(puzzles.count))
        withAnimation {
            self.progressBar = progress
        }
    }
    
    func isSelected(letter: Letter) -> Bool {
        return selectedLetters.contains { currentLetter in
            return currentLetter.id == letter.id
        }
    }
    
    func generateGrid() -> [[Letter]] {
        for item in currentPuzzle.letters.enumerated() {
            let textSize = textSize(character: item.element)
            
            currentPuzzle.letters[item.offset].textSize = textSize
        }
        
        var gridArray: [[Letter]] = []
        var tempArray: [Letter] = []
        
        var currentWidth: CGFloat = 0
        let totalScreenWidth: CGFloat = UIScreen.main.bounds.width - 30
        
        for character in currentPuzzle.letters {
            currentWidth += character.textSize
            
            if currentWidth < totalScreenWidth {
                tempArray.append(character)
            } else {
                gridArray.append(tempArray)
                tempArray = []
                currentWidth = character.textSize
                tempArray.append(character)
            }
        }
        
        if !tempArray.isEmpty {
            gridArray.append(tempArray)
        }
        
        return gridArray
    }
    
    func textSize(character: Letter) -> CGFloat {
        let font = UIFont.systemFont(ofSize: character.fontSize)
        let attributes = [NSAttributedString.Key.font : font]
        let size = (character.value as NSString).size(withAttributes: attributes)
        
        return size.width + (character.padding * 2) + 15
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
