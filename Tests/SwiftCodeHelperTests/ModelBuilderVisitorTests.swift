import XCTest
@testable import SwiftCodeHelper
import SwiftSoftwareSystemModel

class ModelBuilderVisitorTests: XCTestCase {

    func testCanLoadAClassFromASwiftFile() {
        let builder = SystemModelBuilder()
        let visitor = SystemModellingVisitor(builder: builder)
        let parser = SourceFileParser(filePath: "./testResources/swift/test.swift", visitor: visitor)

        parser.parse()

        XCTAssertEqual(1, builder.systemModel.classes.count)

    }

    func testCanLoadFieldOfAClass() {
        let builder = SystemModelBuilder()
        let visitor = SystemModellingVisitor(builder: builder)
        let parser = SourceFileParser(filePath: "./testResources/swift/ClassWithOneField.swift", visitor: visitor)

        parser.parse()

        guard let clz = builder.systemModel.classes.first(where: { clz in 
            return clz.name == "ClassWithOneField"
        }) else {
            XCTFail("Could not get class")
            return
        }

        XCTAssertEqual(1, clz.properties.count)

    }

    func testCanPickUpAFieldThatIsAProtocol() {

        let builder = SystemModelBuilder()
        let visitor = SystemModellingVisitor(builder: builder)
        
        var parser = SourceFileParser(filePath: "./testResources/swift/ClassThatHasInstanceOfInterfaceImpl.swift", visitor: visitor)
        parser.parse()

        parser = SourceFileParser(filePath: "./testResources/swift/Driver.swift", visitor: visitor)
        parser.parse()

        guard let clz = builder.systemModel.classes.first(where: { clz in 
            return clz.name == "ClassThatHasInstanceOfInterfaceImpl"
        }) else {
            XCTFail("Could not get class")
            return
        }

        XCTAssertEqual(1, clz.properties.count)
        XCTAssertEqual(clz.properties[0].name, "driver")
        XCTAssertEqual(clz.properties[0].type.name, "Driver")

    }

    func testCanDetectExtensionSpecifyingThatClassImplementsProtocol() {
        let builder = SystemModelBuilder()
        let visitor = SystemModellingVisitor(builder: builder)
        
        var parser = SourceFileParser(filePath: "./testResources/swift/ClassWithOneField.swift", visitor: visitor)
        parser.parse()

        parser = SourceFileParser(filePath: "./testResources/swift/Driver.swift", visitor: visitor)
        parser.parse()

        parser = SourceFileParser(filePath: "./testResources/swift/SimpleClassExtension.swift", visitor: visitor)
        parser.parse()

        guard let clz = builder.systemModel.classes.first(where: { clz in 
            return clz.name == "ClassWithOneField"
        }) else {
            XCTFail("Could not get class")
            return
        }

        XCTAssertEqual(1, clz.interfaces.count)
        XCTAssertEqual("Driver", clz.interfaces[0].name)

    }

    static var allTests = [
        ("Can load a class from a swift file", testCanLoadAClassFromASwiftFile),
        ("Can load a field on a class", testCanLoadFieldOfAClass),
        ("Can pick up protocol fields", testCanPickUpAFieldThatIsAProtocol),
        ("Can detect class extension for protocol", testCanDetectExtensionSpecifyingThatClassImplementsProtocol),
    ]

}