//
//  NewSongOfTheMonth.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/08/11.
//

import SwiftUI
import Foundation
import Combine
import Kingfisher

struct NewSongOfTheMonthView: View {
    
    @EnvironmentObject var playState:PlayState
    @StateObject var viewModel:NewSongOfTheMonthViewModel = NewSongOfTheMonthViewModel()
    
    private let rows = [GridItem(.fixed(150),spacing: 10),GridItem(.fixed(150),spacing: 10)]
    
    
    var body: some View {
        AlbumHeader(newSongs: $viewModel.newSongs).environmentObject(playState)
        Divider()
        ScrollView(.horizontal, showsIndicators: false) {
            
            VStack(alignment:.center)
            {
                LazyHGrid(rows: rows, spacing: 10)
                {
                   TwoRowGrid
                }
            }
            
        }
    }
}


struct AlbumHeader: View {
    
    @EnvironmentObject var playState:PlayState
    @Binding var newSongs:[NewSong]
    var body: some View {
        
        
        VStack(alignment:.leading,spacing: 5){
            HStack {
                Text("이달의 신곡").bold().foregroundColor(Color("PrimaryColor"))
                Spacer()
                
                NavigationLink {
                    NewSongMoreView(newsongs: $newSongs).environmentObject(playState)
                } label: {
                    Text("더보기").foregroundColor(.gray)
                }
                
                
            }
        }.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
    }
}



extension NewSongOfTheMonthView{
    
    var TwoRowGrid: some View{
        
        //viewModel.newSongs[0..<6] - > ArraySlice -> Array(Arraylice)
        ForEach(viewModel.newSongs.count < 6 ? viewModel.newSongs: Array(viewModel.newSongs[0..<6]),id:\.self.id){ song in
            
            VStack(alignment:.center){
             
             
                    
                    KFImage(URL(string: song.image)!)
                        .resizable()
                        .frame(width:100,height: 100)
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(10)
                        .overlay {
                            ZStack{
                                Button {
                                    let simpleSong = SimpleSong(song_id: song.song_id, title: song.title, artist: song.artist, image: song.image, url: song.url)
                                    if(playState.currentSong != simpleSong)
                                    {
                                        playState.currentSong =  simpleSong //강제 배정
                                        playState.youTubePlayer.load(source: .url(simpleSong.url)) //강제 재생
                                        playState.uniqueAppend(item: simpleSong) //현재 누른 곡 담기
                                    }
                                  
                                } label: {
                                    Image(systemName: "play.fill").foregroundColor(.white)
                                }

                            }.frame(width:85,height:85,alignment: .topTrailing)
                        }
                        .frame(width: 100, height: 100,alignment: .center)
                
                VStack(alignment:.leading) {
                    Text(song.title).font(.system(size: 13, weight: .semibold, design: Font.Design.default)).lineLimit(1)
                    Text(song.artist).font(.caption).lineLimit(1)
                    Text(viewModel.convertTimeStamp(song.date)).font(.caption2).lineLimit(1).foregroundColor(.gray)
                }.frame(width: 100)
                
            }.padding()
            
        }
        
    }
    
    final class NewSongOfTheMonthViewModel:ObservableObject{
        
        var cancelBag = Set<AnyCancellable>()
        
        @Published var newSongs:[NewSong] = [NewSong]()
        
        init()
        {
            fetchNewSong()
        }
        
        func fetchNewSong() {
            Repository.shared.fetchNewMonthSong()
                .sink { completion in
                    
                    switch completion{
                    case .failure(let err):
                        print(" \(#file) \(#function) \(#line) \(err)")
                        
                    case .finished:
                        print(" \(#file) \(#function) \(#line) Finish")
                    }
                    
                } receiveValue: { [weak self] (rawData:newMonthInfo) in
                    
                    print(rawData.data.count)
                    guard let self = self else {return}
                    
                    self.newSongs = rawData.data
              
                }.store(in: &cancelBag)

        }
        
        
        func convertTimeStamp(_ time:Int) -> String{
            let convTime:String = String(time)
            let year:String = convTime.substring(from: 0, to: 1)
            let month:String = convTime.substring(from: 2, to: 3)
            let day:String = convTime.substring(from: 4, to: 5)
            
                
           return "20\(year).\(month).\(day)"
                                
        }
    }
    
}

struct NewSongOfTheMonth_Previews: PreviewProvider {
    static var previews: some View {
        NewSongOfTheMonthView().environmentObject(PlayState())
    }
}


