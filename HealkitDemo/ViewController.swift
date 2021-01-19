//
//  ViewController.swift
//  HealkitDemo
//
//  Created by Azim Talukdar on 13/01/21.
//

import UIKit
import HealthKit
import HealthKitUI

public enum HKBloodTypeString : Int {

    
    case notSet = 0

    case aPositive = 1

    case aNegative = 2

    case bPositive = 3

    case bNegative = 4

    case abPositive = 5

    case abNegative = 6

    case oPositive = 7

    case oNegative = 8
    
    var name: String {
        switch self {
        case .notSet:
            return "Not Set"
        case .aPositive:
            return "A +ve"
        case .aNegative:
            return "A -ve"
        case .bPositive:
            return "B +ve"
        case .bNegative:
            return "B -ve"
        case .abPositive:
            return "AB +ve"
        case .abNegative:
            return "AB -ve"
        case .oPositive:
            return "O +ve"
        case .oNegative:
            return "O -ve"
        default:
            return "Not Available"
        }
    }
}

public enum HKBiologicalSexString : Int {

    
    case notSet = 0

    case female = 1

    case male = 2

    @available(iOS 8.2, *)
    case other = 3
    
    var name: String {
        switch self {
        case .notSet:
            return "Not Set"
        case .female:
            return "Female"
        case .male:
            return "Male"
        case .other:
            return "Other"
        default:
            return "Not Available"
        }
    }
}

class ViewController: UIViewController {
    
    var healthKitStore = HKHealthStore()
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var lblSex: UILabel!
    @IBOutlet weak var lblBloodType: UILabel!
    @IBOutlet weak var lblHeight: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    
    
    //MARK:- Method Starts -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initSetup()
    }
    
    private func initSetup() {
        //1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            print("isHealthDataAvailable false")
            //            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        //2. Prepare the data types that will interact with HealthKit
        guard   let dateOfBirth =            HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let bloodType =              HKObjectType.characteristicType(forIdentifier: .bloodType),
                let biologicalSex =          HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                //                let _ =                      HKObjectType.categoryType(forIdentifier: .fever),
                let _ =                      HKObjectType.correlationType(forIdentifier: .food),
                let _ =                      HKObjectType.documentType(forIdentifier: .CDA),//Clinical Document Architecture
                let bodyMassIndex =          HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let bodyMass =          HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass),
                let height =                 HKObjectType.quantityType(forIdentifier: .height),
                let bloodGlucose =           HKObjectType.quantityType(forIdentifier: .bloodGlucose),
                let bloodAlchohol =          HKObjectType.quantityType(forIdentifier: .bloodAlcoholContent),
                let bloodPressureSystolic =  HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic),
                let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic),
                let activeEnergy =           HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            
            //                completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
        }
        
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        HKObjectType.workoutType()]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       bloodGlucose,
                                                       bloodAlchohol,
                                                       bloodPressureSystolic,
                                                       bloodPressureDiastolic,
                                                       bodyMass,
                                                       HKObjectType.workoutType(),
                                                       HKObjectType.activitySummaryType()
        ]
        
        //4. Request Authorization
        healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead)
        { (success, error) in
            //          completion(success, error)
            
        }
        self.readAllData()
    }
    
    //MARK: Reading datas
    func readAllData() {
        readAgeAndDOB()
        readSex()
        readBloodtype()
        readHeight()
        readWeight()
    }
    
    
    func readAgeAndDOB() {
        do {
            
            //1. This method throws an error if these data are not available.
            let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
            
            //2. Use Calendar to calculate age.
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year], from: today)
            let thisYear = todayDateComponents.year!
            let ageStr = String(thisYear - birthdayComponents.year!)
            let DobStr = "\(birthdayComponents.day!)-\(birthdayComponents.month!)-\(birthdayComponents.year!)"
            
            lblAge.text = ageStr
            lblDOB.text = DobStr
        } catch {
            lblAge.text = "NA"
            lblDOB.text = "NA"
        }
    }
    
    func readSex() {
        do {
            let biologicalSex = try healthKitStore.biologicalSex()
            let sexStr = HKBiologicalSexString(rawValue:biologicalSex.biologicalSex.rawValue)?.name
            lblSex.text = sexStr
        } catch {
            lblSex.text = "NA"
        }
        
    }
    
    func readBloodtype() {
        do {
            let bloodType = try healthKitStore.bloodType()
            let bloodTypeStr = HKBloodTypeString(rawValue:bloodType.bloodType.rawValue)?.name
            lblBloodType.text = bloodTypeStr
        } catch {
            lblBloodType.text = "NA"
        }
    }
    
    func readHeight(){
        let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample{
                print("Height => \(result.quantity)")
                DispatchQueue.main.async {
                    self.lblHeight.text = "\(result.quantity)"
                }
            }else{
                DispatchQueue.main.async {
                    self.lblHeight.text = "NA"
                }
//                print("OOPS didnt get height \nResults => \(results), error => \(error)")
            }
        }
        healthKitStore.execute(query)
    }
    
    func readWeight(){
        let bodyMass = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let query = HKSampleQuery(sampleType: bodyMass, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample{
                print("bodyMass => \(result.quantity)")
                DispatchQueue.main.async {
                    self.lblWeight.text = "\(result.quantity)"
                }
            }else{
                DispatchQueue.main.async {
                    self.lblWeight.text = "NA"
                }
//                print("OOPS didnt get height \nResults => \(results), error => \(error)")
            }
        }
        healthKitStore.execute(query)
    }
    
    func readHeartRate(){
        let heartRate = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let query = HKSampleQuery(sampleType: heartRate, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
            if let result = results?.first as? HKQuantitySample{
                print("heart rate => \(result.quantity)")
            }else{
//                print("OOPS didnt get heart rate \nResults => \(results), error => \(error)")
            }
        }
        healthKitStore.execute(query)
    }
}

//MARK:- Unused functions -
/*
extension ViewController {
    
    
    private func getAgeSexAndBloodType() throws -> (age: String?,
                                                  sex: String?,
                                                  bloodType: String?,
                                                  Dob: String?,
                                                  height: String?,
                                                  weight: String?) {

        
      do {

        //1. This method throws an error if these data are not available.
        let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
        let biologicalSex =       try healthKitStore.biologicalSex()
        let bloodType =           try healthKitStore.bloodType()
//        let height = HKObjectType.quantityType(forIdentifier: .height)
//        let weight = HKObjectType.quantityType(forIdentifier: .bodyMass)
          
        //2. Use Calendar to calculate age.
        let today = Date()
        let calendar = Calendar.current
        let todayDateComponents = calendar.dateComponents([.year],
                                                            from: today)
        let thisYear = todayDateComponents.year!
        let ageStr = String(thisYear - birthdayComponents.year!)
         
        //3. Unwrap the wrappers to get the underlying enum values.
        let sexStr = HKBiologicalSexString(rawValue:biologicalSex.biologicalSex.rawValue)?.name
        let bloodTypeStr = HKBiologicalSexString(rawValue:bloodType.bloodType.rawValue)?.name
        let DobStr = "\(birthdayComponents.day!)-\(birthdayComponents.month!)-\(birthdayComponents.year!)"
          
        return (ageStr, sexStr, bloodTypeStr, DobStr, "height", "weight")
      }
    }

    
    private func getHeartRate() {
        if HKHealthStore.isHealthDataAvailable() {
//          let healthStore = HKHealthStore()
          let heartRateQuantityType = HKObjectType.quantityType(forIdentifier: .heartRate)!
          let allTypes = Set([HKObjectType.workoutType(),
                              heartRateQuantityType
            ])
            healthKitStore.requestAuthorization(toShare: nil, read: allTypes) { (result, error) in
            if let error = error {
              // deal with the error
              return
            }
            guard result else {
              // deal with the failed request
              return
            }
            // begin any necessary work if needed
            print("Heart rate is \(result)")
          }
        }
    }
    
    private func getHeight() {
        if HKHealthStore.isHealthDataAvailable() {
//          let healthStore = HKHealthStore()
          let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .height)!
          let allTypes = Set([HKObjectType.workoutType(),
                              heartRateQuantityType
            ])
          healthKitStore.requestAuthorization(toShare: nil, read: allTypes) { (result, error) in
            if let error = error {
              // deal with the error
              return
            }
            guard result else {
              // deal with the failed request
              return
            }
            // begin any necessary work if needed
            print("Heigt is \(result)")
//            lblHeight.text = result
          }
        }
    }
    
    private func getWeight() {
        if HKHealthStore.isHealthDataAvailable() {
          let heartRateQuantityType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
          let allTypes = Set([HKObjectType.workoutType(),
                              heartRateQuantityType
            ])
            healthKitStore.requestAuthorization(toShare: nil, read: allTypes) { (result, error) in
            if let error = error {
              // deal with the error
                self.lblWeight.text = "NA"
              return
            }
            guard result else {
              // deal with the failed request
                self.lblWeight.text = "NA"
              return
            }
            // begin any necessary work if needed
            print("weight is \(result)")
//            lblWeight.text = result
          }
        }
    }
}
*/
