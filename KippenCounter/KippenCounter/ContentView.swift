//
//  ContentView.swift
//  Counter-SwiftUI
//
//  Created by Aaron on 20.05.20.
//  Copyright © 2020 Aaron Schwerdtfeger. All rights reserved.
//


import SwiftUI



@available(iOS 14.0, *)
struct ContentView: View {
    
    
    // Counting
    @AppStorage("totalCount") var totalCount: Int = 0 {
        didSet { print("totalCount: \(totalCount),\ttotalRows: \(totalRows)") }
    }
    
    @AppStorage("averageCount") var averageCount: Int = 0
    @AppStorage("totalAverageCount") var totalAverageCount: Int = 0
    
    @AppStorage("resetCount") var resetCount: Int = 0
    
    var toMuch: Bool {
        if totalCount > allowedItemsPerRow * 4 {
            return false
        } else {
            return true
        }
    }
    
    @State var offset = CGSize.zero
    
    
    // Row Handling
    var allowedItemsPerRow: Int = 15
    var totalRows: Int {
        return max(1, Int((Double(totalCount) / Double(allowedItemsPerRow)).rounded(.up)))
    }
    var totalAverageRows: Int {
        return max(1, Int((Double(averageCount) / Double(allowedItemsPerRow)).rounded(.up)))
    }
    
    var rowWidth: CGFloat {
        let width = 18.5 * CGFloat(allowedItemsPerRow) + (CGFloat(allowedItemsPerRow) + 2) * 4
        return width
    }
    
    func items(for row: Int) -> Int {
        let pastItems = (row - 1) * allowedItemsPerRow
        let itemsForRow = self.totalCount - pastItems
        return min(allowedItemsPerRow, itemsForRow)
    }
    
    func itemsAvergae(for row: Int) -> Int {
        let pastItems = (row - 1) * allowedItemsPerRow
        let itemsForRow = self.averageCount - pastItems
        return min(allowedItemsPerRow, itemsForRow)
    }
    
    
    // Reset Button
    @State var longpressed: Bool = false
    @AppStorage("resetRotaion") var resetRotaion: Double = 0
    
    
    // Lung
    @State var pulse: Bool = false
    var lungOpacity: Double {
        if averageCount > allowedItemsPerRow * 4 {
            return 0.1
        } else {
            return 0.0
        }
    }
    @State var deg: Double = 0
    
    
    // View
    var body: some View {
        
        ZStack {
            
            // Count Action
            Rectangle()
                .fill(Color("Background"))
                .edgesIgnoringSafeArea(.all)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onTapGesture {
                    if longpressed {
                        resetRotaion -= 2
                        longpressed = false
                    } else {
                        totalCount += 1
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged {
                            gesture in
                            offset = gesture.translation
                            
                            deg = (Double)(offset.width / -5)
                        }
                        .onEnded {
                            _ in
                            if offset.width > 100 {
                                totalCount += 1
                            }
                            if offset.width < -100 && totalCount > 0 {
                                totalCount -= 1
                            }
                            offset = .zero
                            deg = 0
                            longpressed = false
                        }
                )
            
            
            ZStack {
                
                VStack {
                    
                    
                    
                    // Reset Button
                    Image(systemName: "arrow.2.circlepath")
                        .font(.system(size: 30.0))
                        .foregroundColor(
                            longpressed ? Color("OverAverage") : Color("MainColor"))
                        .scaleEffect(x: longpressed ? 1 : 0.85, y: longpressed ? 1 : 0.85)
                        //.rotationEffect( longpressed ? .degrees(360) : .zero)
                        .rotationEffect(.degrees(resetRotaion * 180))
                        .animation(.spring())
                        .padding(.top, 20)
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    _ in
                                    if longpressed {
                                        totalAverageCount = 0
                                        resetCount = 0
                                        averageCount = 0
                                        totalCount = 0
                                        resetRotaion = 0
                                        longpressed = false
                                        
                                    } else {
                                        resetCount += 1
                                        totalAverageCount += totalCount
                                        averageCount = totalAverageCount / resetCount
                                        totalCount = 0
                                        resetRotaion += 1
                                    }
                                    
                                }
                        )
                        
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 1)
                                
                                .onEnded { _ in
                                    longpressed = true
                                    resetRotaion += 2
                                })
                    
                    
                    // Reset Average Text
                    Text("reset average?")
                        .opacity(longpressed ? 1 : 0)
                        .scaleEffect(x: longpressed ? 1 : 0, y: longpressed ? 1 : 0)
                        .font(.system(size: 22, weight: .medium, design: .monospaced))
                        .animation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 10))
                        .padding(.bottom,  20.0)
                        .gesture(
                            TapGesture()
                                .onEnded{ _ in
                                    if longpressed {
                                        totalAverageCount = 0
                                        resetCount = 0
                                        averageCount = 0
                                        totalCount = 0
                                        resetRotaion = 0
                                        longpressed = false
                                    }
                                }
                            
                        )
                    
                    
                    
                    
                    // Counter Label
                    CounterLabelView(number: $totalCount)
                        .onTapGesture {
                            if longpressed {
                                resetRotaion -= 2
                                longpressed = false
                            } else {
                                totalCount += 1
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onChanged {
                                    gesture in
                                    offset = gesture.translation
                                    
                                    deg = (Double)(offset.width / -5)
                                }
                                .onEnded {
                                    _ in
                                    if offset.width > 100 {
                                        totalCount += 1
                                    }
                                    if offset.width < -100 && totalCount > 0 {
                                        totalCount -= 1
                                    }
                                    offset = .zero
                                    deg = 0
                                    longpressed = false
                                }
                        )
                    
                    
                    Spacer()
                }
                
                
                VStack {
                    Spacer()
                    
                    // Cigarettes
                    ZStack {
                        
                        
                        // average Cigarettes
                        VStack() {
                            if totalRows <= 4 {
                                if self.averageCount > 0 {
                                    
                                    ForEach(1...min(totalAverageRows, 4), id: \.self) {
                                        currentRow in
                                        
                                        CigarettesAverageRowView(items: self.itemsAvergae(for: currentRow),
                                                                 currentRow: currentRow,
                                                                 allowedItemsPerRow: self.allowedItemsPerRow,
                                                                 averageItems: self.averageCount)
                                        
                                    }.padding(.bottom, 110)
                                }
                                Spacer()
                            }
                        }
                        .frame(maxWidth: self.rowWidth)
                        .rotationEffect(.degrees(-180))
                        .scaleEffect(x: -1, y: 1)
                        .animation(.spring())
                        
                        
                        
                        
                        
                        // normal Cigarettes
                        VStack() {
                            if totalRows <= 4 {
                                ForEach(1...min(totalRows, 4), id: \.self) {
                                    currentRow in
                                    
                                    CigarettesRowView(items: self.items(for: currentRow),
                                                      currentRow: currentRow,
                                                      allowedItemsPerRow: self.allowedItemsPerRow,
                                                      averageItems: self.averageCount)
                                    
                                }.padding(.bottom, 110)
                                
                                Spacer()
                            }
                        }
                        .frame(maxWidth: self.rowWidth)
                        .rotationEffect(.degrees(-180))
                        .scaleEffect(x: -1, y: 1)
                        .animation(toMuch ? .easeInOut : .none)
                        
                        
                        
                        
                        
                        
                        Spacer()
                        
                    }
                }
                
            }
            
            VStack{
                
                Image("Lung")
                    .renderingMode(.template)
                    .foregroundColor(Color("OverAverage"))
                    .opacity(toMuch ? lungOpacity : 1)
                    .onTapGesture {
                        self.totalCount += 1
                    }
                    .offset(y: -7)
                    .animation(toMuch ? .spring(response: 0.3) : .spring(response: 0.5))
                    .onAppear {
                        pulse.toggle()
                    }
                    .rotationEffect(.degrees(deg), anchor: .top)
                    .animation(.interpolatingSpring(mass: 5, stiffness: 150, damping: 18))
                    .scaleEffect(x: pulse ? 2 : 1.9, y: pulse ? 2 : 1.9, anchor: .top)
                    .animation(Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true))
                    .onTapGesture {
                        if longpressed {
                            resetRotaion -= 2
                            longpressed = false
                        } else {
                            totalCount += 1
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged {
                                gesture in
                                offset = gesture.translation
                                
                                deg = (Double)(offset.width / -5)
                            }
                            .onEnded {
                                _ in
                                if offset.width > 100 {
                                    totalCount += 1
                                }
                                if offset.width < -100 && totalCount > 0 {
                                    totalCount -= 1
                                }
                                offset = .zero
                                deg = 0
                                longpressed = false
                            }
                    )
                
                
            }
        }
    }
}







struct CounterLabelView: View {
    
    @Binding var number: Int
    
    var body: some View {
        Text("\(number)")
            // .padding()
            .font(.system(size: 120.0, weight: .regular, design: .monospaced))
    }
    
}



struct CigarettesRowView: View {
    
    var items: Int
    var currentRow: Int
    var allowedItemsPerRow: Int
    var averageItems: Int
    
    var body: some View {
        HStack(spacing: 0.0) {
            
            if items > 0 {
                ForEach(1...items, id: \.self) {
                    cigarette in
                    
                    CigaretteView(
                        displayAsAverage:
                            (cigarette + (self.currentRow - 1) * self.allowedItemsPerRow <= self.averageItems) ? true : false
                    )
                    .padding(4.0)
                    
                }
            }
            
            Spacer()
            
        }
    }
    
}



struct CigaretteView: View {
    
    var displayAsAverage: Bool
    
    var body: some View {
        
        Image("Kippe")
            .renderingMode(.template)
            .foregroundColor(displayAsAverage ? Color("MainColor") : Color("OverAverage"))
            .rotationEffect(.degrees(-180))
    }
    
}



struct CigarettesAverageRowView: View {
    
    var items: Int
    var currentRow: Int
    var allowedItemsPerRow: Int
    var averageItems: Int
    
    var body: some View {
        HStack(spacing: 0.0) {
            
            
            ForEach(1...items, id: \.self) {
                cigarette in
                
                Image("Kippe")
                    .renderingMode(.template)
                    .foregroundColor(Color("Average"))
                    .rotationEffect(.degrees(-180))
                    .padding(4.0)
            }
            
            Spacer()
            
        }
    }
    
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.colorScheme, .light)
    }
}
