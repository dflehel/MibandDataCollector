//
//  AppDelegate.swift
//  MibandDataCollector
//
//  Created by Lehel Dénes-Fazakas on 2021. 12. 06..
//
import UIKit
import CoreData
import CoreBluetooth
import BackgroundTasks
import os
import Schedule
import Firebase
import Network
import Reachability


@main
class AppDelegate: UIResponder, UIApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {

    var window: UIWindow?
    var centralManager:CBCentralManager!
    var miBand:MiBand2!
    static var hrdata:MibandDatahrArray = MibandDatahrArray()
    static var actdata:MibandActDataArray = MibandActDataArray()
    static var onconected:DarwinBoolean = false
    var t1 : Task?
    var t2 : Task?
    var ref : DatabaseReference!
    var db:Firestore!
    var reachability:Reachability?
    var remoteConfig: RemoteConfig!
    var num1 = 0
    var num2 = 0
    
    func kimentes(){
           
            if (AppDelegate.onconected == true){
            self.ref = Database.database().reference()
            self.db = Firestore.firestore()
            var reff: DocumentReference? = nil
            var adatok:[String:[String:String]] = [:]
            let batch = db.batch()
            do{
            print("KIIIIIRAS")
            
            let context = self.persistentContainer.viewContext
            let items = try context.fetch(MiBandData.fetchRequest())
                for data in items{
                    let sensor = data.sensor!
                    let time = "\(data.timestamp)"
                    let val = data.value
                    adatok[sensor] = [:]
                }
             for data in items{
                 let sensor = data.sensor!
                 let time = "\(data.timestamp)"
                 let val = data.value
                 //adatok[sensor] = [:]
                 adatok[sensor]?[time] = val
    //             if adatok.keys.contains(sensor) {
    //               // contains key
    //                 adatok[sensor]!.append([time:val])
    //             } else {
    //               // does not contain key
    //                 adatok[sensor] = []
    //                 adatok[sensor]!.append([time:val])
    //             }
               //  adatok[sensor]!.append([time:val])
                 //print(data.userid,data.timestamp,data.sensor,data.value)
                 try context.delete(data)
             }
            }
            catch{
                print(error)
            }
            let citiesRef = db.collection("useres").document("cica")
           // citiesRef.addDocument(data: ["lehel" : adatok])
          //  citiesRef.setValuesForKeys(["lehel" : adatok],merge:true)
         //   citiesRef.setValue(adatok, forKey: "lehel")
            for i in adatok.keys{
                ref.child("\(Auth.auth().currentUser?.uid ?? "")/\(i)").updateChildValues(adatok[i]!)
          //      citiesRef.setData([i:adatok[i]],merge: true)
             //   citiesRef.document("lehel").do.updateData([i:adatok[i]],merge: true)
            }
            }
        }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        registerLocalNotification()
        UserDefaults.standard.setValue("false", forKey: "isProcessingTask")
               centralManager = CBCentralManager()
               centralManager.delegate = self
               self.scheduleLocalNotification(body:"proba",title:"teszt")
        FirebaseApp.configure()
                reachability = try! Reachability()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
                   do{
                     try reachability?.startNotifier()
                   }catch{
                     print("could not start reachability notifier")
                   }
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 0
            remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        num1 = Int(remoteConfig["minutesforhruplode"].numberValue)

            // [START fetch_config_with_callback]
            remoteConfig.fetch { (status, error) -> Void in
              if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                  // ...
                }
              } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
              }
            }
        
       num2 = Int(remoteConfig["hoursoffupdate"].numberValue)

            // [START fetch_config_with_callback]
            remoteConfig.fetch { (status, error) -> Void in
              if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                  // ...
                }
              } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
              }
            }
        return true
    }
    
    @objc func reachabilityChanged(note: Notification) {

          let reachability = note.object as! Reachability

          switch reachability.connection {
          case .wifi:
//              print("Reachable via WiFi")
              
              AppDelegate.onconected = true
//              print(AppDelegate.onconected)
//              self.scheduleLocalNotification(body:"Az ekszök wifi kapcsolata megszünt, amennyiben lehet használjon Wifi kapcsolatot a mobilinternet helyet. Viszont az applikáció igényel internet hozzáférét ", title: "A Wifi kapcsolat megszünt")
          case .cellular:
//              print("Reachable via Cellular")
              AppDelegate.onconected = true
//              print(AppDelegate.onconected)
//              self.scheduleLocalNotification(body:"Az applikáció használ internetet vigzázzon hogy a keretéből ne fusson ki", title: "Az applikáció mobilinternetet használ")
          case .unavailable:
//            print("Network not reachable")
              AppDelegate.onconected = false
//              print(AppDelegate.onconected)
//              self.scheduleLocalNotification(body:"Az applikáció internet kapcsolatot igényel, kérem kapcsolja be az internet elérést. Figyeljen arra, hogy amenyibben lehet, Wifi kapcsolatot használjon az adatforgalom csökentése érdekében", title: "Az internetkapcsolat megszünt")
          case .none:
              print("none")
          }
        }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
          
            completionHandler(.newData)
        }
    
    
    private func registerBackgroundTaks() {
                
                
                
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "proba.hrrefresh", using: nil) { task in
                    //This task is cast with processing request (BGAppRefreshTask)
                self.scheduleLocalNotification(body:"szia", title: "uram")
                    os_log("Error: %@", log: .default, type: .error, "regi")
                    self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
                }
            }
    
    func applicationWillResignActive(_ application: UIApplication) {
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
            print("ujraactive")
        }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
            // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
            print("eloter")
           
            
        }
    func applicationDidBecomeActive(_ application: UIApplication) {
           // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
        print("becomeactive")
        
        
        
        if self.t1 == nil{
                self.t1 = Plan.every(num1.minute).do(){
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let dataa = AppDelegate.hrdata.getaverage()
                    AppDelegate.hrdata.cleardata()
                    let acdataa = AppDelegate.actdata.utolsoelem
                    if let vc = appDelegate.window!.rootViewController as? ViewController{
                        let currentTime = Date()
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short

                        let dataa = AppDelegate.hrdata.getaverage()
                        vc.aggregatehr.text = "\(formatter.string(from: currentTime))  \(dataa.getvalue())"

                       // vc.step.text = "\(acdataa!.generatevalue())"


                    }
                    do{

                       // let items = try context.fetch(MiBandData.fetchRequest())
                       // for data in items{
                            //print(data.userid,data.timestamp,data.sensor,data.value)
                           // try context.delete(data)
                       // }

                        var mibanddata = MiBandData(context: self.persistentContainer.viewContext)
                        mibanddata.sensor = dataa.getsensor()
                        mibanddata.userid = dataa.getuserid()
                        mibanddata.value = dataa.getvalue()
                        mibanddata.timestamp = dataa.gettimestamp()
                        try self.persistentContainer.viewContext.save()
                        mibanddata = MiBandData(context: self.persistentContainer.viewContext)
                        mibanddata.sensor = acdataa!.sensor
                        mibanddata.userid = acdataa!.userid
                        mibanddata.value = acdataa!.generatevalue()
                        mibanddata.timestamp = acdataa!.timestamp!
                        try self.persistentContainer.viewContext.save()
                      //  print("sikeres mentes")
                    }catch{
                        print(error)
                    }
                    //if let viewController = self.window?.rootViewController as? MelViewController {
                     //  viewController.updateTime()
                    // }
                    // os_log("Error: %@", log: .default, type: .error, "dfhkjdagfdkhjfgskjhf")

                }
                }
        
        if self.t2     == nil {
            self.t2 = Plan.every(num2.hour).do {
            
        //                    do{
        //                    print("KIIIIIRAS")
        //                    let context = self.persistentContainer.viewContext
        //                    let items = try context.fetch(MiBandData.fetchRequest())
        //                     for data in items{
        //                         print(data.userid,data.timestamp,data.sensor,data.value)
        //                         try context.delete(data)
        //                     }
        //                    }
        //                    catch{
        //                        print(error)
        //                    }
                    self.kimentes()
                        }
                }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
            // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
            // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
           // self.cancelAllPandingBGTask()
          //  cancelAllPandingBGTask()
            //        scheduleAppRefresh()
            print("background")
        }
    
    func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
            // Saves changes in the application's managed object context before the application terminates.
            print("vege")
            reachability!.stopNotifier()
            NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
            self.saveContext()
        }


    // MARK: UISceneSession Lifecycle
//
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
       // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
//
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MibandDataCollector")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state{
            case .poweredOn:
                print("poweredOn")
                let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE])
                
                if lastPeripherals.count > 0{
                    let device = lastPeripherals.first! as CBPeripheral;
                    miBand = MiBand2(device);
                    if (Auth.auth().currentUser?.uid != nil){
                        let vc = window?.rootViewController as? ViewController
                        vc?.mibandconnectionlabel.text = "Connecting to Miband"
                        centralManager.connect(miBand.peripheral, options: nil)
                        vc?.mibandconnectionlabel.text = "Miband Connected"
                        
                        vc?.statuslabel.text = "Az alkalmazás rendeltetésszerűen működik"
                        vc?.statuslabel.textColor = .black
                        vc?.statuslabel.backgroundColor = .green
                    }
                }
                else {
                    let vc = window?.rootViewController as? ViewController
                    vc?.statuslabel.text = " Az alkalmazás nem működik: kérjük csatlakoztassa a Miband szenzort, vagy ellenőrizze a Mifit alkalmazás működését"
                    vc?.statuslabel.textColor = .white
                    vc?.statuslabel.backgroundColor = .red
                    vc?.mibandconnectionlabel.text = "Miband disconnected"
                    centralManager.scanForPeripherals(withServices: [MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE], options: nil)
                }
                
            case .poweredOff:
                print("power Off")
                let vc = window?.rootViewController as? ViewController
                vc?.statuslabel.text = " Az alkalmazás nem működik: kérjük regisztráljon be, vagy jelentkezzen be"
                vc?.statuslabel.textColor = .white
                vc?.statuslabel.backgroundColor = .red
                vc?.mibandconnectionlabel.text = "Miband Disconected"
                
                
                self.scheduleLocalNotification(body:"Kérem kapcsolja vissza a bluetooth kapcsolatot a telefonján", title: "A bluetooth kapcsolat megszünt")
            
                
                
            default:
                print(central.state)
            }
        }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      
            if(peripheral.name?.contains("Mi") != false){
                miBand = MiBand2(peripheral)
                print("try to connect to \(peripheral.name)")
                self.centralManager.stopScan()
                if (Auth.auth().currentUser?.uid != nil){
                    let vc = window?.rootViewController as? ViewController
                    vc?.statuslabel.text = "Az alkalmazás rendeltetésszerűen működik"
                    vc?.statuslabel.textColor = .black
                    vc?.statuslabel.backgroundColor = .green
                    vc?.mibandconnectionlabel.text = "Connecting to Miband"
                    centralManager.connect(miBand.peripheral, options: nil)
                    vc?.mibandconnectionlabel.text = "Miband Connected"
                }
              
                self.scheduleLocalNotification(body:"A Miband eszköz újracsatlakozott. Kérem figyeljen oda az eszköz és a telefon tavolságára!", title: "Miband eszköz csatlakozott")
            }else{
                print("discovered: \(peripheral.name)")
            }
        
            
            
        }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){

            if(peripheral.name?.contains("Mi") != false){
                self.scheduleLocalNotification(body:"A Miband eszköz lecsatlakozott. kérem kapcsolja vissza az eszközt, vagy térjen vissza a telefon hatótávjába", title: "Miband eszköz lecsatlakozott")
                let vc = window?.rootViewController as? ViewController
                vc?.statuslabel.text = " Az alkalmazás nem működik: kérjük csatlakoztassa a Miband szenzort, vagy ellenőrizze a Mifit alkalmazás működését"
                vc?.statuslabel.textColor = .white
                vc?.statuslabel.backgroundColor = .red
                self.centralManager.scanForPeripherals(withServices: [MiBand2Service.UUID_SERVICE_MIBAND2_SERVICE], options: nil)
            }
        
            //peripheral.discoverServices(nil)
            
            
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
                
                
            if let servicePeripherals = peripheral.services as [CBService]?
            {
                for servicePeripheral in servicePeripherals
                {
                    peripheral.discoverCharacteristics(nil, for: servicePeripheral)
                    
                }
                
            }
        }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           if let charactericsArr = service.characteristics  as [CBCharacteristic]?{
               for cc in charactericsArr{
                   switch cc.uuid.uuidString{
                   case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
                       peripheral.readValue(for: cc)
                       peripheral.setNotifyValue(true, for: cc)
                       break
                   case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
                       peripheral.readValue(for: cc)
                       peripheral.setNotifyValue(true, for: cc)
                    //   miBand
                       break
                   case MiBand2Service.UUID_CHARACTERISTIC_7_REALTIME_STEPS.uuidString:
                       self.updateSteps()
                       peripheral.setNotifyValue(true, for: cc)
                       break
                   case MiBand2Service.UUID_CHARACTERISTIC_3_CONFIGURATION.uuidString:
                       // set time format: var rawArray:[UInt8] = [0x06,0x02, 0x00, 0x01]
                       var rawArray:[UInt8] = [0x0a,0x20, 0x00, 0x00]
                       let data = NSData(bytes: &rawArray, length: rawArray.count)
                       peripheral.writeValue(data as Data, for: cc, type: .withoutResponse)
                   default:
                       print("Service: "+service.uuid.uuidString+" Characteristic: "+cc.uuid.uuidString)
                       break
                   }
               }
               
               
           }
       }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            switch characteristic.uuid.uuidString{
            case "FF06":
                var u16:Int
                if (characteristic.value != nil){
                    u16 = (characteristic.value! as NSData).bytes.bindMemory(to: Int.self, capacity: characteristic.value!.count).pointee
                }else{
                    u16 = 0
                }
                print("\(u16) steps")
            case MiBand2Service.UUID_CHARACTERISTIC_6_BATTERY_INFO.uuidString:
                
                updateBattery(miBand.getBattery(batteryData: characteristic.value ?? Data()))
            case MiBand2Service.UUID_CHARACTERISTIC_HEART_RATE_DATA.uuidString:
                updateHeartRate(miBand.getHeartRate(heartRateData: characteristic.value ?? Data()))
            case MiBand2Service.UUID_CHARACTERISTIC_7_REALTIME_STEPS.uuidString:
                //print("lepes")
                //updateSteps()
                miBand.getSteps()
            case MiBand2Service.UUID_CHARACTERISTIC_5_ACTIVITY_DATA.uuidString:
                print("activity")
            default:
                print(characteristic.uuid.uuidString)
            }
        }
    
    
    func updateSteps(){
            print("step")
            if let (steps, distance, calories) = miBand.getSteps(){
                
             //   self.stepsLabel.text = steps.description
             //   self.distanceLabel.text = distance.description+" m"
            //    self.caloriesLabel.text = calories.description+" kcal"
            }
        }
        
    func updateHeartRate(_ heartRate:Int){
            self.stopHeartBeatAnimation()
           //miBand.startVibrate()
         //   self.heartRateLabel.text = heartRate.description
        }
    
    
    func updateBattery(_ battery:Int){
           if battery == 30{
               self.scheduleLocalNotification(body: "Kérem tegye fel a szenzort töltőre", title: "Miband szenzor akkumulátora 30% alá csökkent")
            //   self.batteryImageView.image = #imageLiteral(resourceName: "batteryFull")
           }else if battery == 20{
               self.scheduleLocalNotification(body: "Kérem tegye fel a szenzort töltőre", title: "Miband szenzor akkumulátora 20% alá csökkent")
           //    self.batteryImageView.image = #imageLiteral(resourceName: "battery75")
           }else if battery == 10{
               self.scheduleLocalNotification(body: "Kérem tegye fel a szenzort töltőre", title: "Miband szenzor akkumulátorának állapota kritikus")
           //    self.batteryImageView.image = #imageLiteral(resourceName: "battery50")
           }
         //  self.batteryLabel.text = battery.description+"%"
       }
    
    
    func startHeartBeatAnimation(){
            let pulse1 = CASpringAnimation(keyPath: "transform.scale")
            pulse1.duration = 0.6
            pulse1.fromValue = 1.0
            pulse1.toValue = 1.12
            pulse1.autoreverses = true
            pulse1.repeatCount = 1
            pulse1.initialVelocity = 0.5
            pulse1.damping = 0.8
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = 1.5
            animationGroup.repeatCount = 1000
            animationGroup.animations = [pulse1]
            
            
          //  self.heartRateImageView.layer.add(animationGroup, forKey: "pulse")
        }
        
        func stopHeartBeatAnimation(){
          //  self.heartRateImageView.layer.removeAllAnimations()
        }

    
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            miBand.peripheral.delegate = self
            miBand.peripheral.discoverServices(nil)
            print(peripheral)
           // self.connectionLabel.text = miBand.peripheral.name
           // self.connectionImageView.image = #imageLiteral(resourceName: "connectionFilled")
        }
        

}


extension AppDelegate {
    
    func cancelAllPandingBGTask() {
          BGTaskScheduler.shared.cancelAllTaskRequests()
      }
    
    func scheduleAppRefresh() {
           let request = BGAppRefreshTaskRequest(identifier: "proba.hrrefresh")
           //request.earliestBeginDate = Date().addingTimeInterval(TimeInterval(60)) // App Refresh after 2 minute.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)
        
           //Note :: EarliestBeginDate should not be set to too far into the future.
           do {
               os_log("Error: %@", log: .default, type: .error, "sche")
               try BGTaskScheduler.shared.submit(request)
               os_log("Error: %@", log: .default, type: .error, "she2")
           } catch {
               print("Could not schedule app refresh: \(error)")
           }
       }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {
            //Todo Work
            /*
             os_log("Error: %@", log: .default, type: .error, "dfhkjdagfdkhjfgskjhf")
             //AppRefresh Process
             */
      //  scheduleAppRefresh()
      //  scheduleLocalNotification()
      
          
        let quee = OperationQueue()
        quee.maxConcurrentOperationCount = 1
        os_log("Error: %@", log: .default, type: .error, "handeled")
            task.expirationHandler = {
                //This Block call by System
                task.setTaskCompleted(success: false)
                //Canle your all tak's & queues
            }
       

           // Start the operation.
          //
            task.setTaskCompleted(success: true)
        
        }
    
    
}

extension AppDelegate {
    
    func registerLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func scheduleLocalNotification(body:String,title:String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.fireNotification(body: body, title: title)
                
            }
            
        }
    }
    
    func fireNotification(body:String,title:String) {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.threadIdentifier = "Miban"
        notificationContent.summaryArgument = "Ertesites"
        notificationContent.sound = UNNotificationSound.default
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let now = Date()
        var millisecondsSince1970:Int64 {
                return Int64((now.timeIntervalSince1970 * 1000.0).rounded())
            }
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "local_notification\(String(millisecondsSince1970))", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
}

