//
//  ObservableDemo.swift
//  SiriDemo
//
//  Created by Itsuki on 2024/10/23.
//

import SwiftUI

@Observable
class CountManager: ObservableObject {
//    @ObservationIgnored
    var count: Int = 0
    
    func increment() {
        count += 1
    }
}

struct ObservableDemo: View {
    @Environment(CountManager.self) private var countManager

    var body: some View {
        VStack(spacing: 36) {
            Text("\(countManager.count)")
            Button(action: {
                countManager.increment()
            }, label: {
                Text("Increment")
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.2))
    }
}

struct WrapperView: View {
    @State var countManager = CountManager()
    var body: some View {
        ObservableDemo()
            .environment(countManager)
    }
}



@Observable
class Counter {
    var count: Int = 0
}

struct CounterView: View {
    @Bindable var counter: Counter
    var body: some View {
        VStack(spacing: 36) {
            Text("Count: \(counter.count)")
            TextField("Counter", value: $counter.count, format: .number)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.2))
    }
}

struct CounterWrapperView: View {
//    @State var counter = Counter()
    var body: some View {
        CounterView(counter: Counter())
    }
}



#Preview {
    WrapperView()
}
