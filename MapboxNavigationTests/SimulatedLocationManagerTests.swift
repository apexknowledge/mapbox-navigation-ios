import XCTest
import FBSnapshotTestCase
@testable import MapboxCoreNavigation
@testable import MapboxNavigation
import MapboxDirections

class SimulatedLocationManagerTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
        agnosticOptions = [.OS, .device]
    }

    func testSimulateRouteDoublesBack() {
        let routeExpectation = expectation(description: "Gets a matching route")
        var route: Route!
        Fixture.getRoutesFromMatches(at: "sthlm-double-back") { (waypoints, routes, error) in
            route = routes?[0]
            routeExpectation.fulfill()
        }
        wait(for: [routeExpectation], timeout: 1)
        guard route != nil else { return }
        
        let locationManager = SimulatedLocationManager(route: route)
        let locationManagerSpy = SimulatedLocationManagerSpy()
        locationManager.delegate = locationManagerSpy
        locationManager.speedMultiplier = 5
        
        while locationManager.currentDistance < route.distance {
            locationManager.tick()
        }
        
        locationManager.delegate = nil
        
        let view = RoutePlotter(frame: CGRect(origin: .zero, size: CGSize(width: 1000, height: 1000)))
        view.route = route
        view.locationPlotters = [LocationPlotter(locations: locationManagerSpy.locations, color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 0.5043463908), drawIndexesAsText: true)]
        
        FBSnapshotVerifyView(view)
    }
    

}

class SimulatedLocationManagerSpy: NSObject, CLLocationManagerDelegate {
    var locations = [CLLocation]()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations.append(contentsOf: locations)
    }
}
