import Foundation
import Testing
//import XCTest
//@testable import MyApp
//
//final class MyAppTests: XCTestCase {
//    func test_twoPlusTwo_isFour() {
//        XCTAssertEqual(2+2, 4)
//    }
//}

extension Tag {
    @Tag static var mainHome: Self
}

@Suite(" UI - Main Home tests", .tags(.mainHome))
class MainHomeTests {
    

    @Test("데이터가 하나도없다면, EmptyAddView를 보여준다")
    func showEmptyAddView() async throws {
        
    }
    
    @Test("tag가 하나도없다면, tag뷰를 보여주지않는다.")
    func notShowTagView() async throws {
        
    }
    
    @Test("tag를 처음 fetch해오면 모두 선택되어있어야한다.")
    func allTagSelectedAfterFetch() async throws {
        
    }
    
}
