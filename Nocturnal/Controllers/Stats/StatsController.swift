//
//  StatsController.swift
//  Nocturnal
//
//  Created by Boray Chen on 2022/6/14.
//

import UIKit
import Charts
import Lottie

class StatsController: UIViewController, ChartViewDelegate {

    // MARK: - Properties
    private var user: User
    
    private lazy var pieChartView = PieChartView(frame: .zero)
    
    private lazy var barChartView = BarChartView(frame: .zero)
    
    private var currentJoinedEvents: [Event] = [] {
        didSet {
            if currentJoinedEvents.count == 0 {
                configureAnimationView()
                configureEmptyWarningLabel()
            } else {
                loadingAnimationView.stop()
                emptyWarningLabel.removeFromSuperview()
                resetData()
                self.fetchEventStyles()
                self.setupStyleCounts()
                self.calculateCost()
                self.setupPieChart()
                self.setupBarChart()
            }
        }
    }
    
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
    
    private let loadingAnimationView: AnimationView = {
       let view = AnimationView(name: "empty-box")
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.animationSpeed = 1
        view.backgroundColor = .clear
        view.play()
        return view
    }()
    
    private let emptyWarningLabel: UILabel = {
       let label = UILabel()
        label.text = "No Available Data yet"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.fetchJoinedEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        presentLoadingView(shouldPresent: true)
        fetchCurrentUser { [weak self] user in
            guard let self = self else { return }
            self.user = user
            self.fetchJoinedEvents()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        loadingAnimationView.stop()
        emptyWarningLabel.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    private func fetchJoinedEvents() {
        presentLoadingView(shouldPresent: true)
        EventService.shared.fetchEvents(fromEventIds: user.joinedEventsId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let events):
                self.currentJoinedEvents = events
                self.presentLoadingView(shouldPresent: false)
            case .failure(let error):
                print("Fail to fetch events \(error)")
            }
        }
    }
    
    private func fetchCurrentUser(completion: @escaping (User) -> Void) {
        UserService.shared.fetchUser(uid: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                self.presentErrorAlert(title: "Error", message: "\(error.localizedDescription)", completion: nil)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func resetData() {
        rockCounts = 0
        rappingCounts = 0
        edmCounts = 0
        discoCounts = 0
        hippopCounts = 0
        jazzCounts = 0
        kpopCounts = 0
        metalCounts = 0
        costs = []
        joinedEventStyles = []
    }
    
    private func configureEmptyWarningLabel() {
        view.addSubview(emptyWarningLabel)
        emptyWarningLabel.centerX(inView: loadingAnimationView)
        emptyWarningLabel.anchor(top: loadingAnimationView.bottomAnchor, paddingTop: 15)
    }
    
    private func configureAnimationView() {
        view.addSubview(loadingAnimationView)
        loadingAnimationView.centerY(inView: view)
        loadingAnimationView.centerX(inView: view)
        loadingAnimationView.widthAnchor.constraint(equalToConstant: view.frame.size.width - 20).isActive = true
        loadingAnimationView.heightAnchor.constraint(equalTo: loadingAnimationView.widthAnchor).isActive = true
        loadingAnimationView.play()
    }
    
    private func stopAnimationView() {
        loadingAnimationView.stop()
        loadingAnimationView.alpha = 0
        loadingAnimationView.removeFromSuperview()
    }
    
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

        var entries: [BarChartDataEntry] = []
        
        for index in 0..<currentJoinedEvents.count {
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
