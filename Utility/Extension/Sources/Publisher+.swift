//
//  Publisher+.swift
//  Extension
//
//  Created by A_Mcflurry on 2/1/25.
//

import Combine

extension Publisher {
    func sink<Object: AnyObject>(
        with obj: Object,
        receiveCompletion: @escaping (Object, Failure) -> Void,
        receiveValue: @escaping (Object, Output) -> Void
    ) -> AnyCancellable {
        sink { [weak obj] completion in
            guard let obj = obj else { return }
            switch completion {
            case .finished:
                break
            case .failure(let error):
                receiveCompletion(obj, error)
            }
        } receiveValue: { [weak obj] value in
            guard let obj = obj else { return }
            receiveValue(obj, value)
        }
    }
    
    func sink<Object: AnyObject>(
        with obj: Object,
        receiveValue: @escaping (Object, Output) -> Void
    ) -> AnyCancellable where Failure == Never {
        sink { [weak obj] value in
            guard let obj = obj else { return }
            receiveValue(obj, value)
        }
    }
}
