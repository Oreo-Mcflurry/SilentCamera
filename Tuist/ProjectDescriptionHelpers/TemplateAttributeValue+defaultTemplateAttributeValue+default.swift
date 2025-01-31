//
//  TemplateAttributeValue+defaultTemplateAttributeValue+default.swift
//  AppManifests
//
//  Created by A_Mcflurry on 1/31/25.
//

import Foundation
import ProjectDescription

public extension Template.Attribute.Value {
    static var defaultYear: Template.Attribute.Value {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        
        return .string(dateFormatter.string(from: Date()))
    }
    
    static var defaultDate: Template.Attribute.Value {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        return .string(dateFormatter.string(from: Date()))
    }
    
    static var defaultAuthor: Template.Attribute.Value {
        return .string(ProcessInfo.processInfo.fullUserName)
    }
}
