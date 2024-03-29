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
    
    private let pieChartDescriptionLabel: UILabel = {
       let label = UILabel()
        label.text = "Joined event style distribution"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var pieChartView = PieChartView(frame: .zero)
    
    private lazy var barChartView = BarChartView(frame: .zero)
    
    private let barChartDescriptionLabel: UILabel = {
       let label = UILabel()
        label.text = "Costs per event"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
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
        
        pieChartView.removeFromSuperview()
        barChartView.removeFromSuperview()
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
                self.presentLoadingView(shouldPresent: false)
                self.presentErrorAlert(title: "Error", message: "\(error.localizedDescription)", completion: nil)
                print("Fail to fetch events in states VC \(error)")
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
                self.presentLoadingView(shouldPresent: false)
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
        view.addSubview(pieChartDescriptionLabel)
        pieChartDescriptionLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                        right: view.rightAnchor,
                                        paddingTop: 15,
                                        paddingRight: 15)
        
        view.addSubview(pieChartView)
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pieChartView.topAnchor.constraint(equalTo: pieChartDescriptionLabel.bottomAnchor, constant: 10),
            pieChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            pieChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            pieChartView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
                
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
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries)
        pieChartDataSet.colors = ChartColorTemplates.pastel()
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
        view.addSubview(barChartDescriptionLabel)
        barChartDescriptionLabel.anchor(top: pieChartView.bottomAnchor, right: view.rightAnchor, paddingTop: 5, paddingRight: 15)
        
        view.addSubview(barChartView)
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            barChartView.topAnchor.constraint(equalTo: barChartDescriptionLabel.bottomAnchor, constant: 10),
            barChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            barChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            barChartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        var entries: [BarChartDataEntry] = []
        for index in 0..<currentJoinedEvents.count {
            entries.append( BarChartDataEntry(x: Double(index + 1), y: costs[index]))
        }
        
        let set = BarChartDataSet(entries: entries, label: "Cost")
        set.barShadowColor = UIColor.black
        set.barBorderWidth = 1
        set.barBorderColor = UIColor.lightGray
        let data = BarChartData(dataSet: set)
        
        barChartView.data = data
        barChartView.delegate = self
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = false
        barChartView.xAxis.drawLabelsEnabled = false
        barChartView.legend.enabled = false
    }
}
