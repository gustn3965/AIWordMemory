//import SwiftUI
//
//public struct ContentView: View {
//    public init() {}
//
//    public var body: some View {
//        Text("{{name}}")
//            .padding()
//    }
//}
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//

import Kronos
import Foundation

@globalActor public actor ClockManager {
    
    public static let shared: ClockManager = ClockManager()
    
    public func fetchClock() async -> Date {
        return await withCheckedContinuation { conitunation in
            Clock.sync { date, offset in
                print("현재 정확한 시간: \(date)")
                let timeZone = TimeZone.current
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let localTimeString = dateFormatter.string(from: date)
                print("현재 정확한 시간: \(localTimeString)")
                print("현재 디바이스시간: \(dateFormatter.string(from: Date()))")
                conitunation.resume(returning: date)
            }
        }
    }
}
