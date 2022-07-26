//
//  NocturnalTests.swift
//  NocturnalTests
//
//  Created by Boray Chen on 2022/7/21.
//

import XCTest
@testable import Nocturnal
@testable import FirebaseFirestore
class NocturnalTests: XCTestCase {
    // how to test singleton
    var sut: ExploreController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        let user = User(name: "", email: "", country: "", profileImageURL: "", birthday: Timestamp(date: Date()), gender: 0, numberOfHostedEvents: 0, bio: "", joinedEventsId: [], blockedUsersId: [], requestedEventsId: [])
        sut = ExploreController(user: user)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testWithinSevendays() throws {
        let dateAfterSevenDays = Calendar(identifier: .gregorian).date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let testingEvents = [
            Event(title: "pool party", createTime: Timestamp(date: Date()), hostID: "1", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "dark party", createTime: Timestamp(date: Date()), hostID: "2", description: "", startingDate: Timestamp(date: dateAfterSevenDays), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "animal party", createTime: Timestamp(date: Date()), hostID: "3", description: "", startingDate: Timestamp(date: dateAfterSevenDays), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "rap party", createTime: Timestamp(date: Date()), hostID: "4", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: [])
        ]
        
        sut.events = testingEvents
        
        sut.filterEvents(for: dateAfterSevenDays)
        
        XCTAssertEqual(sut.events, [testingEvents[1], testingEvents[2]])
    }
    
    func testSearchText() {
        let resultEvents: [Event] = [
            Event(title: "pool party", createTime: Timestamp(date: Date()), hostID: "", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "pool", createTime: Timestamp(date: Date()), hostID: "", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "LiGht party", createTime: Timestamp(date: Date()), hostID: "", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "light", createTime: Timestamp(date: Date()), hostID: "", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: [])
        ]

        sut.events = resultEvents
        sut.filtedEvents = []
        
        sut.filterContentForSearchText("party")
        
        XCTAssertEqual(sut.filtedEvents, [resultEvents[0], resultEvents[2]], "Event search is wrong")
    }
    
    func testGetFilteredEventsFromActiveHosts() {
        
        let testingHosts: [User] = [
            User(id: "1", name: "Ray", email: "", country: "", profileImageURL: "", birthday: Timestamp(date: Date()), gender: 0, numberOfHostedEvents: 0, bio: "", joinedEventsId: [], blockedUsersId: [], requestedEventsId: []),
            User(id: "2", name: "John", email: "", country: "", profileImageURL: "", birthday: Timestamp(date: Date()), gender: 0, numberOfHostedEvents: 0, bio: "", joinedEventsId: [], blockedUsersId: [], requestedEventsId: []),
            User(id: "3", name: "Unknown User", email: "", country: "", profileImageURL: "", birthday: Timestamp(date: Date()), gender: 0, numberOfHostedEvents: 0, bio: "", joinedEventsId: [], blockedUsersId: [], requestedEventsId: []),
            User(id: "4", name: "Steven", email: "", country: "", profileImageURL: "", birthday: Timestamp(date: Date()), gender: 0, numberOfHostedEvents: 0, bio: "", joinedEventsId: [], blockedUsersId: [], requestedEventsId: [])
        ]
        
        let testingEvents: [Event] = [
            Event(title: "pool party", createTime: Timestamp(date: Date()), hostID: "1", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "dark party", createTime: Timestamp(date: Date()), hostID: "2", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "animal party", createTime: Timestamp(date: Date()), hostID: "3", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: []),
            Event(title: "rap party", createTime: Timestamp(date: Date()), hostID: "4", description: "", startingDate: Timestamp(date: Date()), destinationLocation: GeoPoint(latitude: 0, longitude: 0), fee: 0, style: "", eventImageURL: "", eventMusicURL: "", eventVideoURL: "", participants: [], deniedUsersId: [], pendingUsersId: [])
        ]
     
        sut.events = testingEvents
        let resultEvents = sut.getFilteredEventsFromActiveHosts(hosts: testingHosts)
        
        XCTAssertEqual(resultEvents, [testingEvents[0], testingEvents[1], testingEvents[3]])
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
