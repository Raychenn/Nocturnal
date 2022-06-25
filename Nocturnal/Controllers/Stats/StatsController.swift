//
//  StatsController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import Charts

class StatsController: UIViewController, ChartViewDelegate {

    // MARK: - Properties
    private let user: User
    
    private lazy var pieChartView = PieChartView(frame: .zero)
    
    private lazy var barChartView = BarChartView(frame: .zero)
    
    private var currentJoinedEvents: [Event] = []
    
    private var joinedEventStyles: [EventStyle] = []
    
    var rockCounts: Double = 0
    var rappingCounts: Double = 0
    var edmCounts: Double = 0
    var discoCounts: Double = 0
    var hippopCounts: Double = 0
    var jazzCounts: Double = 0
    var kpopCounts: Double = 0
    var metalCounts: Double = 0
    var costs: [Double] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        fetchJoinedEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    private func fetchJoinedEvents() {
        EventService.shared.fetchEvents(fromEventIds: user.joinedEventsId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let events):
                self.currentJoinedEvents = events
                self.fetchEventStyles()
                self.setupPieChart()
                self.calculateCost()
                self.setupBarChart()
            case .failure(let error):
                print("Fail to fetch events \(error)")
            }
        }
    }
    
    // MARK: - Helpers
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Stats"
    }
    
    func fetchEventStyles() {
        self.currentJoinedEvents.forEach { event in
            self.joinedEventStyles.append(EventStyle(rawValue: event.style) ?? .rapping)
            print("joined Events \(self.joinedEventStyles)")
        }
    }
    
    func calculateCost() {
        self.currentJoinedEvents.forEach { event in
            self.costs.append(Double(event.fee))
        }
    }
    
    func setupPieChart() {
        view.addSubview(pieChartView)
        pieChartView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 300)
        
        pieChartView.chartDescription.text = "Monthly joined event styles"
        
        setupStyleCounts()
        
        let dataEntries: [PieChartDataEntry] = [
            PieChartDataEntry(value: rockCounts, label: "Rock"),
            PieChartDataEntry(value: rappingCounts, label: "Rapping"),
            PieChartDataEntry(value: edmCounts, label: "EDM"),
            PieChartDataEntry(value: discoCounts, label: "Disco"),
            PieChartDataEntry(value: hippopCounts, label: "HipPop"),
            PieChartDataEntry(value: jazzCounts, label: "Jazz"),
            PieChartDataEntry(value: kpopCounts, label: "Kpop"),
            PieChartDataEntry(value: metalCounts, label: "Metal")
        ]
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "Event Types Distribution")
        pieChartDataSet.colors = ChartColorTemplates.joyful()
        let chartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = chartData
    }
    
    func setupStyleCounts() {
        joinedEventStyles.forEach { style in
            switch style {
            case .rock:
                rockCounts += 1
            case .rapping:
                rappingCounts += 1
            case .edm:
                edmCounts += 1
            case .disco:
                discoCounts += 1
            case .hippop:
                hippopCounts += 1
            case .jazz:
                jazzCounts += 1
            case .kpop:
                kpopCounts += 1
            case .metal:
                metalCounts += 1
            }
        }
    }
    
    func setupBarChart() {
        view.addSubview(barChartView)
        
        barChartView.anchor(top: pieChartView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 15, paddingRight: 15, height: 300)

        // Configure Axis
//        let xAxis = barChart.xAxis
//        xAxis.labelFont = UIFont.systemFont(ofSize: 20, weight: .black)
        
        var entries: [BarChartDataEntry] = []
        
        for index in 0..<joinedEventStyles.count {
            entries.append(BarChartDataEntry(x: Double(index), y: costs[index]))
        }
        
        let set = BarChartDataSet(entries: entries, label: "Cost")
        set.barShadowColor = UIColor.black
        set.barBorderWidth = 1
        set.barBorderColor = UIColor.lightGray
        let data = BarChartData(dataSet: set)
        
        barChartView.data = data
        barChartView.delegate = self
    }
}
