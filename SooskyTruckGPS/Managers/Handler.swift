//
//  Handler.swift
//  Base_MVVM_Combine
//
//  Created by Trịnh Xuân Minh on 02/02/2024.
//

import Foundation

typealias Handler = (() -> Void)
typealias DateHandler = (Date) -> Void
typealias RangeDateHandler = ((Date?), Date?) -> Void
typealias HandlerString = ((String) -> Void)
typealias RatingHandler = ((Int) -> Void)
typealias TrainingTypeHandler = ((TrainingType) -> Void)
