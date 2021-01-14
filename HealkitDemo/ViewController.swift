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
            return "A Positive"
        case .aNegative:
            return "A Negative"
        case .bPositive:
            return "B Positive"
        case .bNegative:
            return "B Negative"
        case .abPositive:
            return "AB Positive"
        case .abNegative:
            return "AB Negative"
        case .oPositive:
            return "O Positive"
        case .oNegative:
            return "O Negative"
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
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            
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
                                                       HKObjectType.workoutType()]

        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead)
        { (success, error) in
//          completion(success, error)
        }
        
        do {
          let userAgeSexAndBloodType = try getAgeSexAndBloodType()
            lblBloodType.text = String(userAgeSexAndBloodType.age)
            lblSex.text = HKBiologicalSexString(rawValue: userAgeSexAndBloodType.biologicalSex.rawValue)?.name
            lblBloodType.text = HKBloodTypeString(rawValue: userAgeSexAndBloodType.bloodType.rawValue)?.name
            print(userAgeSexAndBloodType.biologicalSex)
        } catch let error {
//          self.displayAlert(for: error)
        }

    }
    
    
    private func getAgeSexAndBloodType() throws -> (age: Int,
                                                  biologicalSex: HKBiologicalSex,
                                                  bloodType: HKBloodType) {

        
      do {

        //1. This method throws an error if these data are not available.
        let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
        let biologicalSex =       try healthKitStore.biologicalSex()
        let bloodType =           try healthKitStore.bloodType()
          
        //2. Use Calendar to calculate age.
        let today = Date()
        let calendar = Calendar.current
        let todayDateComponents = calendar.dateComponents([.year],
                                                            from: today)
        let thisYear = todayDateComponents.year!
        let age = thisYear - birthdayComponents.year!
         
        //3. Unwrap the wrappers to get the underlying enum values.
        let unwrappedBiologicalSex = biologicalSex.biologicalSex
        let unwrappedBloodType = bloodType.bloodType
          
        return (age, unwrappedBiologicalSex, unwrappedBloodType)
      }
    }

}

