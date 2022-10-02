//
//  HomeViewModel.swift
//  WaktaverseMusic
//
//  Created by YoungK on 2022/10/02.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    @Published var nowChart: [RankedSong] = [RankedSong]()
    var subscription = Set<AnyCancellable>()

    init() {
        fetchTop20(category: .total) // 초기화  chart는 누적으로 지정
    }

    func fetchTop20(category: TopCategory) {
        Repository.shared.fetchTop20(category: category)
            .sink { _ in

            } receiveValue: { [weak self] (datas: [RankedSong]) in

                guard let self = self else {return}

                self.nowChart = datas  // chart 갱신

            }.store(in: &subscription)
    }

}
