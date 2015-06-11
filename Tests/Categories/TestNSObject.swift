import Foundation
import PromiseKit
import XCTest

private class Foo: NSObject {
    dynamic var bar: String = "bar"
}

class TestNSObject: XCTestCase {
    func testKVO() {
        let ex = expectationWithDescription("")

        let foo = Foo()
        foo.observe("bar").then { (newValue: String) -> Void in
            // using XCTAssertEqual here crashes Swift 2.0
            // this worries me, since it seems more likely we have
            // an ARC problem, but I can’t see what it would be.
            XCTAssert(newValue == "moo")
            ex.fulfill()
        }.snatch { err in
            XCTFail()
        }
        foo.bar = "moo"

        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testAfterlife() {
        let ex = expectationWithDescription("")
        var killme: NSObject!

        autoreleasepool {

            func innerScope() {
                killme = NSObject()
                afterlife(killme).then { _ -> Void in
                    //…
                    ex.fulfill()
                }
            }

            innerScope()

            after(0.2).then {
                killme = nil
            }
        }

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
