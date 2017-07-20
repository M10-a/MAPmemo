//
//  ViewController.swift
//  Mymap
//
//  Created by 浅野未央 on 2017/05/26.
//  Copyright © 2017年 mio. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth

class ViewController: UIViewController ,UITextFieldDelegate , MKMapViewDelegate , CLLocationManagerDelegate {
  
  // Mapモデルのインスタンス生成
  var MapList = [maplist]()
  
  // Firebaseのインスタンス生成
  var ref: DatabaseReference!
  private var databaseHandle: DatabaseHandle!
  
  var locationManager: CLLocationManager!
  var location: CLLocationCoordinate2D!
  var pin = MKPointAnnotation()
  
  
  // FirebaseのID
  var uid = ""
  
  
  override func viewDidAppear(_ animated: Bool) {
    
    
    
    // 現在地にフォーカスを合わせる
    dispMap.setCenter(dispMap.userLocation.coordinate, animated: true)
    // ユーザの位置に追従させる
    dispMap.userTrackingMode = MKUserTrackingMode.follow
    
   
    // ユーザ情報を取得
    let user = Auth.auth().currentUser
    if user == nil {
      performSegue(withIdentifier: "goAuth", sender: nil)
    } else {
      uid = (user?.uid)!
    }
  
    // delegateの通知先を指定
    dispMap.delegate = self
    

    // Text Fieldのdelegate通知先を設定
    inputText.delegate = self
    
    // タップした時のアクションを追加
    let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
    dispMap.addGestureRecognizer(tapGesture)
    
    // MapView Delegate設定
    dispMap.delegate = self
    
    // Firebaseのインスタンス生成
    ref = Database.database().reference()
    
   //  databaseの監視を開始  
    startObservingDatabase()
    
  }
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // inputText
  @IBOutlet weak var inputText: UITextField!
  
  // dispMap
  @IBOutlet weak var dispMap: MKMapView!
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    // キーボードを閉じる(1)  Bool型
    textField.resignFirstResponder()
    
    // 入力された文字を取り出す(2) 定数
    let searchKeyword = textField.text
    
    // 入力された文字をデバックエリアに表示(3)
    print(searchKeyword ?? "値が入っていません")
    
    // CLGeocoderインスタンスを取得(5)
    let geocodeder = CLGeocoder()
    
    //入力された文字から情報を取得(6)
    geocodeder.geocodeAddressString(searchKeyword!, completionHandler: { (Placemark:[CLPlacemark]?, error:Error?) in
      
      //位置情報を取得する場合1件目の情報を取り出す(7)
      if let placemark = Placemark?[0] {
        
        //位置情報から緯度経度をtargetCoordinateに取り出す(8)
        if let tergetCoordnate = placemark.location?.coordinate{
          
          // 緯度経度をデバックエリアに表示(9)
          print(tergetCoordnate)
          
          //MKPointAnnotationインスタンスを取得し、ピンを作成(10)
          let pin = MKPointAnnotation()
          
          // ピンの置く場所に緯度経度を設定(11)
          pin.coordinate = tergetCoordnate
          
          // ピンのタイトルを設定(12)
          pin.title = searchKeyword
          
          // ピンを地図に置く(13)
          self.dispMap.addAnnotation(pin)
          
          // 緯度経度を中心にして半径500mの範囲を表示
          self.dispMap.region = MKCoordinateRegionMakeWithDistance(tergetCoordnate ,500.0, 500.0 )
        }
      }
    })
    // デフォルト動作を行うのでtrueを返す(4)
    return true
  }
  
  
  // UITapGestureRecognizer(長押し)
  func mapTapped(_ sender: UITapGestureRecognizer){
    
    // 画面上のタッチした座標を取得
    let tapPoint = sender.location(in: dispMap)
    
    // タッチした座標からマップ上の緯度経度を取得
    let location = dispMap.convert(tapPoint, toCoordinateFrom: dispMap)
    
    // ToDo入力するダイヤログを生成
    let dialog = UIAlertController(title: "memo", message: "", preferredStyle: .alert)
    
    // OKボタン生成
    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
      
      
      
      
      
      
      // 入力されたテキストを保持
      if let userInput = dialog.textFields?.first?.text {
        
        // MKPointAnnotationインスタンスを取得し、ピンを生成(10)
        let pin = MKPointAnnotation()
        
        // ピンの置く場所に緯度経度を設定(11)
        pin.coordinate = location
        
        // ピンのタイトルを設定(12)
        pin.title = userInput
        
        // ピンを地図に置く(13)
        self.dispMap.addAnnotation(pin)
        
        // detabaseにデータ更新
        let setData: [String: Any] = ["title":userInput, "latitude":location.latitude, "longitude":location.longitude]
        self.ref.child("users").child(self.uid).child("memo").childByAutoId().child("data").setValue(setData)
        
      }
    }
    
    
    // ダイヤログをリセット
    dialog.addTextField(configurationHandler: nil)
    
    // ダイヤログにボタンを付与
    dialog.addAction(okAction)
    
    // ダイヤログを表示
    present(dialog, animated: true, completion: nil)
  }
  
  
  func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    mapView.selectAnnotation(self.pin, animated: true)
    
  }
  
  
  // 切り替えボタン
  @IBAction func changeMapButtonAction(_ sender: Any) {
    // mapTypeプロパティ値をトグル
    // standard(標準)
    if dispMap.mapType == .standard {
      // satellite(航空写真)
      dispMap.mapType = .satellite
      
    } else if dispMap.mapType == .satellite {
      // hybrid(航空写真+標準)
      dispMap.mapType = .hybrid
      
    } else if dispMap.mapType == .hybrid {
      // hybrid(3D Flyover)
      dispMap.mapType = .satelliteFlyover
      
    } else if dispMap.mapType == .satelliteFlyover{
      // hybrid(3D Flyover+標準)
      dispMap.mapType = .hybridFlyover
      
    } else {
      // 標準に戻る
      dispMap.mapType = .standard
    }
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "pin"
    
    if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
      annotationView.annotation = annotation
      return annotationView
    } else {
      let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
      annotationView.isEnabled = true
      annotationView.canShowCallout = true
      
      
      let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
      let delete_image = UIImage(named: "delete_button")
      
      btn.setImage(delete_image, for: .normal)
      
      annotationView.rightCalloutAccessoryView = btn
      return annotationView
    }
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
    self.ref.child("users/\(self.uid)/memo").observeSingleEvent(of: .value, with: {(snapshot) in
      
      for mapSnapShot in snapshot.children{
        
        let getData = maplist(snapshot: mapSnapShot as! DataSnapshot)

        let location = view.annotation?.coordinate
        
        print(location ?? "no")
        print(getData)
        
        if (getData.latitude == location?.latitude) &&
          (getData.longitude == location?.longitude) {
          getData.ref?.removeValue()
        }
        
      }
      mapView.removeAnnotation(view.annotation!)
    })

  }
  
  func startObservingDatabase() {
    //\(self.uid)文字列に変数をいれる時
    self.ref.child("users/\(self.uid)/memo").observeSingleEvent(of: .value, with: {(snapshot) in
      
      for mapSnapShot in snapshot.children{
        
        let getData = maplist(snapshot: mapSnapShot as! DataSnapshot)
        
        
        // MKPointAnnotationインスタンスを取得し、ピンを生成(10)
        let pin = MKPointAnnotation()
        
        // ピンの置く場所に緯度経度を設定(11)
        let location = CLLocationCoordinate2D(latitude:  getData.latitude!, longitude:  getData.longitude!)
        pin.coordinate = location
        
        // ピンのタイトルを設定(12)
        pin.title =  getData.title
        
        // ピンを地図に置く(13)
        self.dispMap.addAnnotation(pin)
        
      }
    })
  }
  
  @IBAction func didTapSignOut(_ sender: Any) {
    do {
      try Auth.auth().signOut()
      performSegue(withIdentifier: "goAuth", sender: nil)
    } catch let error {
      assertionFailure("Error signing out: \(error)")
    }
  }
  
 
  }
