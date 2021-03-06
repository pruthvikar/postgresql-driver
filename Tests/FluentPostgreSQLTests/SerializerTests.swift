import XCTest
import Node
@testable import FluentPostgreSQL

class SerializerTests: XCTestCase {
    static let allTests = [
        ("testSerializerInsert", testSerializerInsert),
        ("testSerializerInsertRemovesNullID", testSerializerInsertRemovesNullID),
        ("testSerializerInsertWorksWithoutID", testSerializerInsertWorksWithoutID),
    ]

    func testSerializerInsert() throws {
        let input = Node.object([
            "id": Node.string("foo"),
            "name": Node.string("bar")
        ])
        
        let serializer = PostgreSQLSerializer(sql: .insert(table: "test", data: input))
        let result = serializer.serialize()

        if result.0.hasPrefix("INSERT INTO test (id, name) VALUES ($1, $2)") {
            XCTAssertEqual(2, result.1.count)
            XCTAssertEqual(Node.string("foo"), result.1.first ?? Node.null)
            XCTAssertEqual(Node.string("bar"), result.1.last ?? Node.null)
        } else if result.0.hasPrefix("INSERT INTO test (name, id) VALUES ($1, $2)") {
            XCTAssertEqual(2, result.1.count)
            XCTAssertEqual(Node.string("bar"), result.1.first ?? Node.null)
            XCTAssertEqual(Node.string("foo"), result.1.last ?? Node.null)
        } else {
            XCTFail("serialize() returned an unexpected SQL statement: \(result.0)")
        }
    }
    
    func testSerializerInsertRemovesNullID() throws {
        let input = Node.object([
            "id": Node.null,
            "name": Node.string("bar")
        ])

        let serializer = PostgreSQLSerializer(sql: .insert(table: "test", data: input))
        let result = serializer.serialize()
        
        XCTAssertTrue(result.0.hasPrefix("INSERT INTO test (name) VALUES ($1)"),
                      "Unexpected serialized query string: '\(result.0)'")
        XCTAssertEqual(1, result.1.count)
        XCTAssertEqual(Node.string("bar"), result.1.first ?? Node.null)
    }
    
    func testSerializerInsertWorksWithoutID() throws {
        let input = Node.object([
            "name": Node.string("bar")
        ])

        let serializer = PostgreSQLSerializer(sql: .insert(table: "test", data: input))
        let result = serializer.serialize()
        
        XCTAssertTrue(result.0.hasPrefix("INSERT INTO test (name) VALUES ($1)"),
                      "Unexpected serialized query string: '\(result.0)'")
        XCTAssertEqual(1, result.1.count)
        XCTAssertEqual(Node.string("bar"), result.1.first ?? Node.null)
    }
}
