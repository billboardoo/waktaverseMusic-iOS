//
//  PlayListView.swift
//  Billboardoo
//
//  Created by yongbeomkwak on 2022/08/01.
//

import SwiftUI
import UIKit
import Kingfisher
import ScalingHeaderScrollView

struct PlayListView: View {
    @EnvironmentObject var playState: PlayState
    @EnvironmentObject var player: PlayerViewModel
    @State private var multipleSelection = Set<UUID>() // 다중 선택 셋
    @State var draggedItem: SimpleSong? // 현재 드래그된 노래

    var body: some View {

        ZStack(alignment: .top) {
            BlurView()

            VStack {
                if let song = playState.currentSong {
                    VStack(alignment: .leading) {
                        Button {
                            withAnimation(.easeInOut) { player.playerMode.mode = .full }
                        } label: {
                            Image(systemName: "xmark").font(.title).foregroundColor(.primary)
                                .padding()
                        }

                        Text("지금 재생 중").font(.custom("PretendardVariable-Bold", size: Device.isPhone ? 13 : 20)).foregroundColor(.primary).bold() .padding(.leading, 10)

                        HStack {
                            NowPlaySongView(song: song)
                            Spacer()
                        }
                        .padding(.leading, 10)
                        .animation(.easeIn, value: playState.currentSong)

                        HStack {
                            TopLeftControlView(playList: $playState.playList.list, currentIndex: $playState.playList.currentPlayIndex, multipleSelection: $multipleSelection).environmentObject(playState)
                            Spacer()
                            TopRightControlView(playList: $playState.playList.list, currentIndex: $playState.playList.currentPlayIndex, multipleSelection: $multipleSelection).environmentObject(playState).padding(.trailing, 10)
                        }

                    }
                }

                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack {

                        ForEach(playState.playList.list, id: \.self.id) { song in

                            ItemCell(song: song, multipleSelection: $multipleSelection).environmentObject(playState)
                                .background(song.song_id == playState.currentSong?.song_id ? Color("SelectedSongBgColor") : .clear)

                            // - MARK: 드래그 앤 드랍으로 옮기기
                                .onDrag {
                                    self.draggedItem = song // 드래그 된 아이템 저장
                                    return NSItemProvider(item: nil, typeIdentifier: song.title)
                                }

                                .onDrop(of: [song.title], delegate: MyDropDelegate(currentItem: song, currentIndex: $playState.playList.currentPlayIndex, playList: $playState.playList.list, draggedItem: $draggedItem))

                        }

                    }
                }
            }

        }.padding(.top, 1)

    }

}

struct ItemCell: View {
    @EnvironmentObject var playState: PlayState
    var song: SimpleSong // 해당 셀 노래
    @Binding var multipleSelection: Set<UUID> // 다중 선택 셋
    @State var draggedItem: SimpleSong? // 드래그 된 아이템

    var body: some View {
        HStack {
            Button {
                withAnimation(.spring()) {
                    // 해당 음악이 이미 선택된 상태(다중 선택 셋에 있음) 이면 선택 취소(remove), 아니면 선택 추가(insert)
                    if multipleSelection.contains(song.id) {
                        multipleSelection.remove(song.id)
                    } else {
                        multipleSelection.insert(song.id)
                    }
                }
            } label: {
                // 다중 선택 셋 안에 해당 음악이 있을 때 는 check circle 없으면 empty circle
                Image(systemName: multipleSelection.contains(song.id) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: Device.isPhone  ? 20 : 25)).foregroundColor(Color.primary)
                    .padding(.leading, 10)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text(song.title).modifier(PlayBarTitleModifier())
                    Text(song.artist).modifier(PlayBarArtistModifer())
                }
                Spacer()

                Image(systemName: "line.3.horizontal").font(.system(size: Device.isPhone  ? 20 : 25)).foregroundColor(Color.primary).padding(.trailing, 5)
            }
            .padding(.all)
            .background(song.song_id == playState.currentSong?.song_id ? Color("SelectedSongBgColor") : .clear)

        }
        .contentShape(Rectangle()) // 행 전체 클릭시 바로 재생되기 위해
        .onTapGesture {
            playState.currentSong = song
            playState.youTubePlayer.load(source: .url(song.url)) // 강제 재생
            playState.playList.currentPlayIndex = playState.playList.list.firstIndex(of: song) ?? 0
        }

    }

}

struct MyDropDelegate: DropDelegate {
    let currentItem: SimpleSong
    @Binding var currentIndex: Int
    @Binding var playList: [SimpleSong]
    @Binding var draggedItem: SimpleSong?

    /*
     
     MyDropDelegate - validateDrop() called
     MyDropDelegate - dropEntered() called
     MyDropDelegate - dropExited() called
     MyDropDelegate - validateDrop() called
     MyDropDelegate - dropEntered() called
     MyDropDelegate - performDrop() called
     
     */

    // 드랍에서 벗어났을 때
    func dropExited(info: DropInfo) {

    }

    // 드랍 처리 (드랍을 놓을 때 작동)
    func performDrop(info: DropInfo) -> Bool {

        return true
    }

    // 드랍 변경
    func dropUpdated(info: DropInfo) -> DropProposal? {

        return nil
    }

    // 드랍 유효 여부
    func validateDrop(info: DropInfo) -> Bool {

        return true
    }

    // 드랍 시작

    func dropEntered(info: DropInfo) {

        guard let draggedItem = self.draggedItem else {
            return
        }

        if draggedItem != currentItem { // 현재 드래그 아이템과 현재 내 아이템과 다르면
            let from = playList.firstIndex(of: draggedItem)!
            let to = playList.firstIndex(of: currentItem)!

            withAnimation {
                // from에서 to로 이동 ,  to > from일 때는 to+1  아니면 to로
                let nowPlaySong: SimpleSong = self.playList[currentIndex] // 현재 재생중인 곳
                self.playList.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to+1 : to)
                // move 함
                self.currentIndex = playList.firstIndex(of: nowPlaySong) ?? 0
                // 옮긴 후 재생이 멈추지 않게 현재 재생중인 곳의 인덱스로 변경
            }

        }

    }

}

struct NowPlaySongView: View {
    let song: SimpleSong
    let div: CGFloat = 8

    var body: some View {
        HStack {
            KFImage(URL(string: song.image.convertFullThumbNailImageUrl())!)
                .placeholder({
                    Image("placeHolder")
                        .resizable()
                        .frame(width: ScreenSize.width/div, height: ScreenSize.width/div)
                        .transition(.opacity.combined(with: .scale))
                })
                .resizable()
                .downsampling(size: CGSize(width: 200, height: 200)) // 약 절반 사이즈로 다운 샘플링
                .frame(width: ScreenSize.width/div, height: ScreenSize.width/div)
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(song.title).modifier(PlayBarTitleModifier()).foregroundColor(.wak)
                Text(song.artist).modifier(PlayBarArtistModifer())
            }
            Spacer()

        }

    }
}

struct TopLeftControlView: View {
    @EnvironmentObject var playState: PlayState
    @Binding var playList: [SimpleSong]
    @Binding var currentIndex: Int
    @Binding var multipleSelection: Set<UUID>

    var body: some View {
        HStack {
            Button {
                // 전체 선택된 상태면 모두 선택 해제, 아니면 모두 선택
                if multipleSelection.count == playList.count {
                    multipleSelection.removeAll()
                } else {
                    _ = playList.map { multipleSelection.insert($0.id) }
                }
            } label: {
                Label {
                    Text("\(multipleSelection.count)").font(.system(size: Device.isPhone  ? 20 : 25)).foregroundColor(Color.primary)
                } icon: {
                    Image(systemName: multipleSelection.count == playList.count ? "checkmark.circle.fill" : "circle").font(.system(size: Device.isPhone  ? 20 : 25)).foregroundColor(Color.primary).padding(.leading, 10)
                }
            }
        } // HStack
    }
}

struct TopRightControlView: View {
    @EnvironmentObject var playState: PlayState
    @EnvironmentObject var player: PlayerViewModel
    @Binding var playList: [SimpleSong]
    @Binding var currentIndex: Int
    @Binding var multipleSelection: Set<UUID>
    @State var isShowAlert: Bool = false

    var body: some View {
        HStack {
            // 1. 버튼 눌렀을 때 선택된게 있다면 ShowAlert
            Button {
                if multipleSelection.count != 0 { isShowAlert = true }
            } label: {
                Image(systemName: "trash").font(.system(size: Device.isPhone ? 20 : 25)).foregroundColor(Color.primary).padding(.trailing, 10)
            }
            // 2. Alert - 삭제하시겠습니까? 아니요 : 예
            .alert("삭제하시겠습니까?", isPresented: $isShowAlert) {

                // 2-1. 아니요 선택 시 Alert 창 닫힘
                Button(role: .cancel) { } label: { Text("아니요") }

                // 2-2. 예 선택 시 목록에서 제거
                Button(role: .destructive) {
                    if multipleSelection.count == playList.count { // 전체 제거 시
                        withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7)) {
                            playList.removeAll() // 리스트 제거
                            multipleSelection.removeAll() // 셋 제거
                            player.playerMode.mode = .mini // Fullscrren 끄고
                            playState.youTubePlayer.stop() // youtubePlayer Stop
                            playState.currentSong = nil // 현재 재생 노래 비어둠
                        }
                    } else { // 전체 제거가 아닐 때
                        withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.7)) {
                            playList = playList.filter {!multipleSelection.contains($0.id)} // 포함된 것만 제거 , 담기지 않은 것만 남겨둠
                            if multipleSelection.contains(playState.currentSong!.id) { // 현재삭제 목록에 재생중인 노래가 포함됬을 때
                                currentIndex = 0 // 가장 처음 인덱스로
                                playState.playAgain() // 첫번째 곡부터 재생
                            } else {
                                let nowPlaySong: SimpleSong = playState.currentSong!
                                currentIndex = playList.firstIndex(of: nowPlaySong) ?? 0 // 현재 재생중인 노래로
                            }
                            multipleSelection.removeAll() // 멀티셋 비우고
                        }
                    }
                } label: {
                    Text("예")
                }

            }

        }

    }
}
