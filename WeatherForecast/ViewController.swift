//
//  ViewController.swift
//  WeatherForecast
//
//  Created by giftbot on 11/06/2019.
//  Copyright © 2019 giftbot. All rights reserved.
//


// tableView 부모의 scrollView delegate를써서 didscorll될때 애니메이션을 주도록

import CoreLocation
import UIKit
import MapKit

final class Annotation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}

class ViewController: UIViewController {
    
    // MARK: - UI Properties
    let backgroundImageView = UIImageView()
    let currentLocationLabel = UILabel()
    let refreshBtn = UIButton(type: .custom)
    
    let weatherTableView = UITableView()
    
    let weatherTableViewHeaderContainerView = UIView()
    let headerWeatherImageView = UIImageView()
    let headerWeatherTextLabel = UILabel()
    let headerLowestDegreeImageView = UIImageView()
    let headerLowestDegreeTextLabel = UILabel()
    let headerHighestDegreeImageView = UIImageView()
    let headerHighestDegreeTextLabel = UILabel()
    let headerCurrentDegreeTextLabel = UILabel()
    
    // MARK: - Data Properties
    var currentState = "날씨맑음" { didSet { headerWeatherTextLabel.text = currentState } }
    var currentWeatherCode = "" { didSet { headerWeatherImageView.image = UIImage(named: currentWeatherCode) } }
    
    var lowestTemp = "" { didSet { headerLowestDegreeTextLabel.text = String(lowestTemp + "º") } }
    var highestTemp = "" { didSet { headerHighestDegreeTextLabel.text = String(highestTemp + "º") } }
    var currentTemp = "" { didSet { headerCurrentDegreeTextLabel.text = String(currentTemp + "º") } }
    
    var currentTime = "" { didSet { currentLocationLabel.text = "\(currentLocation)\n\(currentTime)" } }
    var currentLocation = "대한민국 서울시 서울동 서울아파트" { didSet { currentLocationLabel.text = "\(currentLocation)\n\(currentTime)" } }
    var currentCoordinate = CLLocation()
    
    var weather3DaysArray = [Weather3Days]()
    
    var weatherTableViewTopAnchorOld =  NSLayoutConstraint()
    var weatherTableViewTopAnchorNew =  NSLayoutConstraint()
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        checkAuthorizationStatus()
        
        setAutoLayout()
        configure()
        setCurrentWeatherData()
        setForecast3daysData()
        
        getCurrentTime()
        
        
    }
    
    private func setAutoLayout() {
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame
        
        view.addSubview(currentLocationLabel)
        currentLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        currentLocationLabel.topAnchor.constraint(equalTo: safeGuide.topAnchor, constant: 0).isActive = true
        currentLocationLabel.centerXAnchor.constraint(equalTo: safeGuide.centerXAnchor).isActive = true
        
        view.addSubview(refreshBtn)
        refreshBtn.translatesAutoresizingMaskIntoConstraints = false
        refreshBtn.topAnchor.constraint(equalTo: safeGuide.topAnchor, constant: 3).isActive = true
        refreshBtn.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor, constant: -10).isActive = true
        refreshBtn.widthAnchor.constraint(equalToConstant: 22).isActive = true
        refreshBtn.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        view.addSubview(weatherTableView)
        weatherTableView.translatesAutoresizingMaskIntoConstraints = false
        weatherTableView.widthAnchor.constraint(equalTo: safeGuide.widthAnchor).isActive = true
//        weatherTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        weatherTableView.topAnchor.constraint(equalTo: currentLocationLabel.bottomAnchor, constant: -3).isActive = true
        weatherTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // =================================== TableView HeaderView 설정 ===================================
        weatherTableView.tableHeaderView = weatherTableViewHeaderContainerView
        weatherTableViewHeaderContainerView.frame = CGRect(x: 0, y: 0, width: weatherTableView.frame.width, height: 150)
        
        weatherTableViewHeaderContainerView.addSubview(headerWeatherImageView)
        headerWeatherImageView.translatesAutoresizingMaskIntoConstraints = false
        headerWeatherImageView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 10).isActive = true
        headerWeatherImageView.topAnchor.constraint(equalTo: weatherTableViewHeaderContainerView.topAnchor, constant: 0).isActive = true
        headerWeatherImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        headerWeatherImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        weatherTableViewHeaderContainerView.addSubview(headerWeatherTextLabel)
        headerWeatherTextLabel.translatesAutoresizingMaskIntoConstraints = false
        headerWeatherTextLabel.topAnchor.constraint(equalTo: weatherTableViewHeaderContainerView.topAnchor, constant: 0).isActive = true
        headerWeatherTextLabel.leadingAnchor.constraint(equalTo: headerWeatherImageView.trailingAnchor, constant: 5).isActive = true
        headerWeatherTextLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        headerWeatherTextLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        weatherTableViewHeaderContainerView.addSubview(headerLowestDegreeImageView)
        headerLowestDegreeImageView.translatesAutoresizingMaskIntoConstraints = false
        headerLowestDegreeImageView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 10).isActive = true
        headerLowestDegreeImageView.topAnchor.constraint(equalTo: headerWeatherImageView.bottomAnchor, constant: 3).isActive = true
        headerLowestDegreeImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        headerLowestDegreeImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        weatherTableViewHeaderContainerView.addSubview(headerLowestDegreeTextLabel)
        headerLowestDegreeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLowestDegreeTextLabel.topAnchor.constraint(equalTo: headerLowestDegreeImageView.topAnchor).isActive = true
        headerLowestDegreeTextLabel.leadingAnchor.constraint(equalTo: headerLowestDegreeImageView.trailingAnchor, constant: 3).isActive = true
        headerLowestDegreeTextLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        headerLowestDegreeTextLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        weatherTableViewHeaderContainerView.addSubview(headerHighestDegreeImageView)
        headerHighestDegreeImageView.translatesAutoresizingMaskIntoConstraints = false
        headerHighestDegreeImageView.topAnchor.constraint(equalTo: headerLowestDegreeImageView.topAnchor).isActive = true
        headerHighestDegreeImageView.leadingAnchor.constraint(equalTo: headerLowestDegreeTextLabel.trailingAnchor, constant: 5).isActive = true
        headerHighestDegreeImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        headerHighestDegreeImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        weatherTableViewHeaderContainerView.addSubview(headerHighestDegreeTextLabel)
        headerHighestDegreeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        headerHighestDegreeTextLabel.leadingAnchor.constraint(equalTo: headerHighestDegreeImageView.trailingAnchor, constant: 3).isActive = true
        headerHighestDegreeTextLabel.topAnchor.constraint(equalTo: headerLowestDegreeImageView.topAnchor).isActive = true
        headerHighestDegreeTextLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        headerHighestDegreeTextLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        weatherTableViewHeaderContainerView.addSubview(headerCurrentDegreeTextLabel)
        headerCurrentDegreeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCurrentDegreeTextLabel.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor, constant: 10).isActive = true
        headerCurrentDegreeTextLabel.topAnchor.constraint(equalTo: headerLowestDegreeImageView.bottomAnchor, constant: 3).isActive = true
        headerCurrentDegreeTextLabel.widthAnchor.constraint(equalTo: safeGuide.widthAnchor, multiplier: 0.7).isActive = true
        headerCurrentDegreeTextLabel.bottomAnchor.constraint(equalTo: weatherTableViewHeaderContainerView.bottomAnchor, constant: -3).isActive = true
        // =========================================================================================================
        
        view.sendSubviewToBack(backgroundImageView)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        
        let topInset = view.frame.height - currentLocationLabel.frame.height - weatherTableViewHeaderContainerView.frame.height - view.safeAreaInsets.top
        
        weatherTableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        weatherTableView.contentOffset = CGPoint(x: 0, y: -topInset)
        
        isDark = false
    }
    
    private func configure() {
        backgroundImageView.image = UIImage(named: "rainy")
        backgroundImageView.contentMode = .scaleAspectFill
        
        currentLocationLabel.backgroundColor = .clear
        currentLocationLabel.font = UIFont.boldSystemFont(ofSize: 12)
        currentLocationLabel.numberOfLines = 0
        currentLocationLabel.textAlignment = .center
        currentLocationLabel.textColor = .white
        currentLocationLabel.text = "경기도 구리시 인창동\n오전 11:57"
        
        refreshBtn.setImage(UIImage(named: "rotateIcon"), for: .normal)
        refreshBtn.adjustsImageWhenHighlighted = false      // false해주면 누를때 누른듯한 느낌의 색이 변하지않도록 막아줌???
        refreshBtn.addTarget(self, action: #selector(refreshBtnDidTap(_:)), for: .touchUpInside)
        
        weatherTableView.dataSource = self
        weatherTableView.delegate = self
        weatherTableView.register(UINib(nibName: "WeatherTableViewCell", bundle: nil), forCellReuseIdentifier: "weatherCell")
        weatherTableView.backgroundColor = .clear
        weatherTableView.rowHeight = 70
        weatherTableView.separatorStyle = .none
        weatherTableView.allowsSelection = false
        weatherTableView.showsVerticalScrollIndicator = false
        
        headerWeatherImageView.image = UIImage(named: "SKY_03")
        
        headerWeatherTextLabel.text = "맑음"
        headerWeatherTextLabel.textColor = .white
        headerWeatherTextLabel.textAlignment = .left
        headerWeatherTextLabel.font = UIFont.systemFont(ofSize: 14)
        
        headerLowestDegreeImageView.image = UIImage(named: "lowestIcon")
        headerLowestDegreeTextLabel.textColor = .white
        headerLowestDegreeTextLabel.textAlignment = .left
        headerLowestDegreeTextLabel.font = UIFont.systemFont(ofSize: 14)
        
        headerHighestDegreeImageView.image = UIImage(named: "highestIcon")
        headerHighestDegreeTextLabel.textColor = .white
        headerHighestDegreeTextLabel.textAlignment = .left
        headerHighestDegreeTextLabel.font = UIFont.systemFont(ofSize: 14)
        
        headerCurrentDegreeTextLabel.textAlignment = .left
        headerCurrentDegreeTextLabel.textColor = .white
        headerCurrentDegreeTextLabel.font = .systemFont(ofSize: 80, weight: .ultraLight)
    
        backgroundImageView.addSubview(blurView)
        blurView.effect = nil
        blurView.frame = CGRect(x: 0, y: 0, width: 1000, height: view.frame.height)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func getCurrentTime() {
        
        let now = Date()
        
        let date = DateFormatter()
        date.locale = Locale(identifier: "ko_kr")
        //        date.dateFormat = "yyyy-MM-dd HH:mm"
        date.dateFormat = "HH:mm"
        
        let time = date.string(from: now)
        
        let calender = Calendar.current
        let components = calender.dateComponents([.hour, .day, .month, .minute], from: now)
        
        
        
        var hour = String(components.hour!).count == 1 ? "0\(components.hour!)" : "\(components.hour!)"
        var minute = String(components.minute!).count == 1 ? "0\(components.minute!)" : "\(components.minute!)"
        
        if components.hour! == 12 {
            currentTime = "오후 \(hour):\(minute)"
        } else if components.hour! >= 13 {
            currentTime = "오후 \(Int(hour)!-12):\(minute)"
        } else {
            currentTime = "오전 \(hour):\(minute)"
        }
        
        
        //        print("🔵🔵🔵 now time: ", time)
        //        print("🔵🔵🔵 now date: ", components.hour, components.day, components.month, components.minute)
        
        //        let time = date.date(from: "2019-06-11")
        
    }
    
    private func setCurrentWeatherData() {
        let apiAddress = "https://api2.sktelecom.com/weather/current/hourly"
            + "?appKey=66b18350-4b00-4eee-aaf9-8e638a3416a0"
            + "&lat=\(currentCoordinate.coordinate.latitude)"
            + "&lon=\(currentCoordinate.coordinate.longitude)"
        
        guard let apiURL = URL(string: apiAddress) else { return print("apiURL conver error!!")}

        let dataTask = URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
            guard error == nil else { return print("datTask error!!") }

            guard let serverData = data else { return print("data convert error!!")}
        
            guard let data = try? JSONSerialization.jsonObject(with: serverData) as? [String: Any]
                else { print("Crurrent WeatherData convert error"); return }
            
            guard let weather = data["weather"] as? [String: Any], let hourly = weather["hourly"] as? [[String: Any]]
                else { print("weather conver error"); return }
            
            
            hourly.forEach{
                if let sky = $0["sky"] as? [String: Any],
                    let code = sky["code"] as? String,
                    let name = sky["name"] as? String {
                    self.currentState = name
                    self.currentWeatherCode = code
                }
                
                if let temperature = $0["temperature"] as? [String: Any],
                    let curTemp = temperature["tc"] as? String,
                    let curTempMax = temperature["tmax"] as? String,
                    let curTempMin = temperature["tmin"] as? String {
                    self.currentTemp = String( floor(Double(curTemp)! * 10 ) / 10 )    // floor다시볼것!!!!!!!!!!!!
                    self.lowestTemp = String( floor(Double(curTempMin)! * 10 ) / 10 )
                    self.highestTemp = String( floor(Double(curTempMax)! * 10 ) / 10 )
                }
            }
            
            for i in 1...14 {       // WeatherCode에 따라 배경 이미지 변경하기
                let boolValue = String(i).count == 1 ? self.currentWeatherCode == "SKY_O0\(i)" : self.currentWeatherCode == "SKY_O\(i)"
                if boolValue {
                    switch i {
                    case 1, 2: self.backgroundImageView.image = UIImage(named: "sunny")
                    case 3, 7: self.backgroundImageView.image = UIImage(named: "clody")
                    case 4, 5, 6, 8, 9, 10: self.backgroundImageView.image = UIImage(named: "rainy")
                    case 11, 12, 13, 14: self.backgroundImageView.image = UIImage(named: "lightning")
                    default: break
                    }
                }
            }
            DispatchQueue.main.async {
                self.weatherTableView.reloadData()
            }
            
            print("🔸🔸🔸 현재 날씨: 온도 \(self.currentTemp)   상태 \(self.currentState)  코드 \(self.currentWeatherCode)  최저\(self.lowestTemp)  최고 \(self.highestTemp)")
        }
        dataTask.resume()
        
        
        
        
        
    }
    
    private func setForecast3daysData() {
        guard let data = try? JSONSerialization.jsonObject(with: forecastData) as? [String: Any]
            else { print("foreCastData convert error"); return }
        
        guard let weather = data["weather"] as? [String: Any], let forecast3days = weather["forecast3days"] as? [[String: Any]] else { print("weather convert error"); return}
        //        print("🔸🔸🔸 foreCastData: ", forecast3days)
        //        print("🔵🔵🔵 timeRelease: ", forecast3days)
        
        
        var timeByServer = Date()
        let dateFormatter = DateFormatter()
        let cal = Calendar.current
        
        forecast3days.forEach{  // 온도 가져오기
            
            if let timeRelease = $0["timeRelease"] as? String {
                //                print("🔵🔵🔵 timeRelease : ", timeRelease)
                
                //                let myValue = "2017-05-29 22:00:00 AM"
                
                var date = DateFormatter()
                date.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                var dateValue = date.date(from: timeRelease)!
                //                print("🔵🔵🔵 현재시간 date값: ", dateValue)
                
                
                
                date.dateFormat = "MM-dd HH:mm"
                let dateStringValue = date.string(from: dateValue)
                //                print("🔵🔵🔵 현재시간 String값: ", dateStringValue)
                
                
                
                date.dateFormat = "MM-dd"
                let monthStringValue = date.string(from: dateValue)
                //                print("🔵🔵🔵 현재 월, 일 String값: ", monthStringValue)
                
                let cal = Calendar.current
                let calValueHour = cal.dateComponents([.month, .day], from: dateValue)
                //                print("🔵🔵🔵 calValueHour: ", calValueHour)
                
                timeByServer = dateValue
                
            }
            
            if let fcst3hour = $0["fcst3hour"] as? [String: Any], let temp = fcst3hour["temperature"] as? [String: Any], let stateImageString = fcst3hour["sky"] as? [String: Any]{
                //                print("🔸🔸🔸 temp: ", temp)
                //                print("🔸🔸🔸 stateImage : ", stateImageString)
                
                var hour = 4 // 시간 초기값 => 이후 for문에서 3씩 더해주면서 데이터를 꺼내주기위함
                for i in 1...20 {
                    guard let value = temp["temp\(hour)hour"] as? String else { return print("value convert error")}
                    
                    guard let stateImageValue = stateImageString["code\(hour)hour"] as? String else { return print("stateImageValue convert error") }
                    let stateImageValueChanged = stateImageValue.replacingCharacters(in: Range(NSRange(location: 4, length: 1), in: stateImageValue)!, with: "O")
                    
                    timeByServer += (3600 * 3)
                    dateFormatter.dateFormat = "HH:mm"
                    let time3days = dateFormatter.string(from: timeByServer)
                    
                    let calComponents = cal.dateComponents([.month, .day, .weekday], from: timeByServer)
                    
                    let date3days = "\(calComponents.month!).\(calComponents.day!) (\(cal.convertIntToDayOfWeek(weekDayIntValue: calComponents.weekday!) ))"
                    
                    //                    print("🔸🔸🔸 time3days: ", time3days )
                    //                    print("🔸🔸🔸 date3days : ", date3days)
                    
                    
                    
                    let weather = Weather3Days(date: date3days, time: time3days, stateImage: stateImageValueChanged, degree: String( Int(Double(value)!)) + "º")
                    //
                    weather3DaysArray.append(weather)
                    
                    hour += 3
                }
            }
        }
        
        
    }
    
    
    @objc func refreshBtnDidTap(_ sender: UIButton) {
        
        startUpdateLocation()
        
        
        
        UIView.animate(withDuration: 0.4) {
            //            sender.transform = sender.transform.rotated(by: CGFloat(360))
            sender.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
            sender.transform = CGAffineTransform.identity
        })
        
        
    }
    
    
    // MARK: - Getting MyLocation
    func checkAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
            //            locationManager.requestAlwaysAuthorization()
            
        case .restricted, .denied :
            // Disable location features
            break
        case .authorizedAlways :
            fallthrough
        case .authorizedWhenInUse :
            //            startUpdateLocation()
            print("Authorized")
        @unknown default: break
        }
    }
    
    func startUpdateLocation() {
        let status = CLLocationManager.authorizationStatus()
        guard status == .authorizedAlways || status == .authorizedWhenInUse else { return }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10.0
        locationManager.startUpdatingLocation()
    }
    
    func getCurrentAddress(coordinate: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(coordinate) { (placeMark, error) in
            if error != nil {
                return print(error!.localizedDescription)
            }
            
            guard let address = placeMark?.first,
                let country = address.country,
                let administrativeArea = address.administrativeArea,
                let locality = address.locality,
                let name = address.name
                else {return}
            
            print("●●●●●● 현재 좌표의 주소 : " + "\(country) \(administrativeArea) \(locality) \(name)")
            self.currentLocation = "\(country) \(administrativeArea) \(locality)"
            self.getCurrentTime()
        }
        locationManager.stopUpdatingLocation()
        
    }
    
    var isDark = true
    var blurView = UIVisualEffectView()
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weather3DaysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        cell.weatherData = weather3DaysArray[indexPath.row]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0) {
//            print("downSide")
//            print("isDark: ", isDark)
            guard isDark == true else { return }
            isDark = false
            
            UIView.animate(withDuration: 1) {
                self.blurView.alpha = 0
                self.backgroundImageView.transform = CGAffineTransform.identity
            }
            
        }
        else {
//            print("upSide")
//            print("isDark: ", isDark)
            
            guard isDark == false else { return }
            isDark = true
            
            UIView.animate(withDuration: 1) {
                self.backgroundImageView.transform =  self.backgroundImageView.transform.translatedBy(x: -10, y: 0)
                self.blurView.effect = UIBlurEffect(style: .dark)
                self.blurView.alpha = 0.8
            }
            view.layoutIfNeeded()
            
        }
        
    }
}


extension Calendar {
    func convertIntToDayOfWeek(weekDayIntValue: Int) -> String {
        var dayOfWeekString = ""
        switch weekDayIntValue {
        case 1 : dayOfWeekString = "Mon"
        case 2 : dayOfWeekString = "Tue"
        case 3 : dayOfWeekString = "Wed"
        case 4 : dayOfWeekString = "Thur"
        case 5 : dayOfWeekString = "Fri"
        case 6 : dayOfWeekString = "Sat"
        case 7 : dayOfWeekString = "Sun"
        default : break
        }
        return dayOfWeekString
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("●●●●●● status ")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("authrorized")
        default :
            print("Unauthorized")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let current = locations.last!
        print("🔸🔸🔸 locationManager current Location: ", current)
        currentCoordinate = CLLocation(latitude: current.coordinate.latitude, longitude: current.coordinate.longitude)
        setCurrentWeatherData()
        getCurrentAddress(coordinate: currentCoordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are no authorized
            print(error)
            return
        }
        // Notify the user of any errors.
    }
}
