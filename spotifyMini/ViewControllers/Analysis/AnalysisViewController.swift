//
//  AnalysisViewController.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/13/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import Foundation
import Intrepid
import Charts

class AnalysisViewController : UIViewController {

    let spotify = Spotify.manager
    var genre: String?
    var analysis: Analysis? {
        willSet {
            self.stopObservingAnalysisNotification()
        } didSet {
            self.registerForAndHandleAnalysisNotification()
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var keysPieChart: PieChartView!
    @IBOutlet weak var valenceLineChart: LineChartView!
    @IBOutlet weak var energyBarChart: BarChartView!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchRecommendedTracksAndSetUpCharts()
    }

    func fetchRecommendedTracksAndSetUpCharts() {
        if let genre = self.genre {
            self.title = genre.uppercaseString
            self.spotify.fetchRecommendedTracks(forGenre: genre) { result in
                if let error = result.error as? SpotifyError {
                    self.presentErrorAlert(error)
                } else if let tracks = result.value {
                    self.analysis = Analysis(tracks: tracks, name: genre)
                    self.analysis?.fetchAnalyses()
                }
            }

            let charts = [self.keysPieChart, self.valenceLineChart, self.energyBarChart ]
            charts.forEach {
                $0.descriptionText = ""
                $0.noDataText = "Analyzing \(genre)..."
                $0.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInBounce)
                $0.layer.cornerRadius = 8
            }
        }
    }

    // MARK: Chart Population

    func setupLineChartForAvgValenceByKey() {
        if let analysis = self.analysis {
            self.valenceLineChart.data = self.lineDataForAvgValenceByKey(analysis)
        }
    }

    func setupPieChartForMostFrequentSongKeys() {
        if let analysis = self.analysis {
            self.keysPieChart.data = self.pieChartDataForKeyFrequency(analysis)
            self.keysPieChart.centerText = "Analyzed Songs\nper Key"
            self.keysPieChart.legend.enabled = false
        }
    }

    func setupBarChartForEnergy() {
        if let analysis = self.analysis {
            self.energyBarChart.data = self.barChartDataForEnergy(analysis)
        }
    }

    // MARK: Chart Data Creation

    func lineDataForAvgValenceByKey(analysis: Analysis, colors: [NSUIColor]? = nil) -> LineChartData {
        var lineDataEntries = [ChartDataEntry]()

        let averages = analysis.averageValenceByKey
        if averages.count == Analysis.keyTitles.count {
            for i in 0..<Analysis.keyTitles.count {
                let avgValenceForThisKey = averages[i]
                let dataEntry = ChartDataEntry(value: Double(avgValenceForThisKey), xIndex: i)
                lineDataEntries.append(dataEntry)
            }
        }

        let lineDataSet = LineChartDataSet(yVals: lineDataEntries, label: "Avg. Valence by Key")
        lineDataSet.axisDependency = .Left
        lineDataSet.circleColors = colors ?? ChartColorTemplates.joyful()
        lineDataSet.setColor(UIColor.greenColor())

        let formatter = NSNumberFormatter()
        formatter.allowsFloats = false
        formatter.numberStyle = .PercentStyle
        lineDataSet.valueFormatter = formatter

        return LineChartData(xVals: Analysis.keyTitles, dataSet: lineDataSet)
    }

    func pieChartDataForKeyFrequency(analysis: Analysis, colors: [NSUIColor]? = nil) -> PieChartData {
        var pieDataEntries = [ChartDataEntry]()

        let keyValues = analysis.keyValues
        for i in 0..<Analysis.keyTitles.count {
            let countOfThisKey = keyValues.filter { $0 == i }.count
            if countOfThisKey > 0 {
                let dataEntry = ChartDataEntry(value: Double(countOfThisKey), xIndex: pieDataEntries.count)
                pieDataEntries.append(dataEntry)
            }
        }

        let pieDataSet = PieChartDataSet(yVals: pieDataEntries, label: "")
        pieDataSet.axisDependency = .Left
        pieDataSet.colors = colors ?? ChartColorTemplates.pastel()
        let formatter = NSNumberFormatter()
        formatter.allowsFloats = false
        pieDataSet.valueFormatter = formatter
        return PieChartData(xVals: Analysis.keyTitles, dataSet: pieDataSet)
    }

    func barChartDataForEnergy(analysis: Analysis, colors: [NSUIColor]? = nil) -> BarChartData {

        var dataEntries = [BarChartDataEntry]()

        let buckets = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0] as [Float]
        let values = analysis.energyValues
        for (index, upperLimit) in buckets.enumerate() {
            let lowerLimit = upperLimit - 0.1
            let countOfValuesWithinLimits = values.filter { $0 < upperLimit && $0 > lowerLimit }.count

            let dataEntry = BarChartDataEntry(value: Double(countOfValuesWithinLimits), xIndex: index)
            dataEntries.append(dataEntry)
        }

        let dataSet = BarChartDataSet(yVals: dataEntries, label: "# of Tracks per Energy Level (0.0 - 1.0)")
        dataSet.axisDependency = .Left
        dataSet.colors = colors ?? ChartColorTemplates.joyful()

        let bucketTitles = buckets.map { String($0) }
        return BarChartData(xVals: bucketTitles, dataSet: dataSet)
    }

    // MARK: Notification Handling

    func registerForAndHandleAnalysisNotification() {
        NSNotificationCenter.defaultCenter().addObserverForName(AnalysisFetchedTrackInfoNotification, object: self.analysis, queue: nil) { notification in
            if let error = notification.userInfo?[AnalysisNotificationErrorUserInfoKey] as? NSError,
                let spotifyError = SpotifyError(error: error) {
                self.presentErrorAlert(spotifyError)
            } else {
                self.title = self.analysis?.name.uppercaseString
                self.setupPieChartForMostFrequentSongKeys()
                self.setupLineChartForAvgValenceByKey()
                self.setupBarChartForEnergy()
            }
        }
    }

    func stopObservingAnalysisNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AnalysisFetchedTrackInfoNotification, object: self.analysis)
    }
}
