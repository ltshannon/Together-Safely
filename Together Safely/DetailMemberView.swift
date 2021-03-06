//
//  DetailMemberView.swift
//  Together Safely
//
//  Created by Larry Shannon on 11/28/20.
//  Copyright © 2020 Larry Shannon. All rights reserved.
//

import SwiftUI

struct DetailMemberView: View {
    
    var title: String
    var groupId: String
    var phoneNumber: [String]
    var members: FetchRequest<CDMember>
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var messages: FetchRequest<CDMessages>
    var group: FetchRequest<CDGroups>
    let userPhoneNumber =  UserDefaults.standard.value(forKey: "userPhoneNumber") as? String ?? ""
    @State private var textMsg = ""
    let context = DataController.appDelegate.persistentContainer.viewContext
    @State private var name: String = ""
    
    init(title: String, groupId: String, phoneNumber: [String], members: FetchRequest<CDMember>) {
        self.title = title
        self.groupId = groupId
        self.phoneNumber = phoneNumber
        self.members = members
        
        var predicate: NSPredicate
        var predicates: [NSPredicate] = []
        for number in phoneNumber {
            predicates.append(NSPredicate(format: "phoneNumber == %@", number))
        }
        predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        predicates.removeAll()
        let groupPredicate = NSPredicate(format: "groupId == %@", groupId)
        predicates.append(groupPredicate)
        predicates.append(predicate)
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        messages = FetchRequest<CDMessages>(entity: CDMessages.entity(),
                                            sortDescriptors: [NSSortDescriptor(keyPath: \CDMessages.timeStamp, ascending: true)],
                                         predicate: finalPredicate)
        
        group = FetchRequest<CDGroups>(entity: CDGroups.entity(), sortDescriptors: [], predicate: NSPredicate(format: "groupId == %@", groupId))
        
    }
    
    @FetchRequest(
        entity: CDContactInfo.entity(),
        sortDescriptors: []
    ) var contactInfo: FetchedResults<CDContactInfo>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            if messages.wrappedValue.count > 0 {
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { value in
                        ForEach((0...messages.wrappedValue.count-1), id: \.self) { index in
                            let messagePhone = messages.wrappedValue[index].phoneNumber ?? ""
                            VStack(alignment: .leading, spacing: 0) {
                                Text("")
//                                Text(messages.wrappedValue[index].phoneNumber ?? "")
//                                    .font(Font.custom("Avenir-Medium", size: 15))
                                Text(name.getName(phoneName: messages.wrappedValue[index].phoneNumber ?? "", contacts: contactInfo))
                                    .font(Font.custom("Avenir-Medium", size: 15))
                                    .padding(.bottom, 5)
                                Text(messages.wrappedValue[index].textString ?? "")
                                    .padding()
                                    .font(Font.custom("Avenir-Medium", size: 15))
                                    .background(Color("Colorwhite"))
                                    .clipShape(msgTail(mymsg: messagePhone == userPhoneNumber ? true : false))
                            }
                            .frame(maxWidth: .infinity, alignment: messagePhone == userPhoneNumber ? .trailing : .leading)
                        }
                        .onChange(of: messages.wrappedValue.count, perform: {count in
                            print("count: \(count)")
                            value.scrollTo(messages.wrappedValue.count - 1, anchor: .bottom)
                        })
                        .onAppear {
                            value.scrollTo(messages.wrappedValue.count - 1, anchor: .bottom)
                        }
                    }
                }
            } else {
                Spacer()
            }
            HStack(spacing: 15) {
                TextField("Enter Message", text: $textMsg)
                    .padding(.horizontal)
                    .font(Font.custom("Avenir-Medium", size: 15))
                    .frame(height: 45)
                    .background(Color("Colorwhite"))
                    .clipShape(Capsule())
                if textMsg != "" {
                    Button(action: {
                        WebService.setStatus(text: textMsg, emoji: "", groupId: groupId){ successful in
                            if !successful {
                                print("Set status in DetailMemberView failed for groupId : \(groupId))")
                            } else {
                                textMsg = ""
                            }
                        }
                    }, label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(Color("Color1"))
                            .clipShape(Circle())
                    })
                    
                }
            }
            .animation(.default)
            .padding()
        }
            .padding([.leading, .trailing, .bottom], 15)
            .navigationTitle(title)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Image("backgroudImage").resizable().edgesIgnoringSafeArea(.all))
            .onDisappear() {
                for member in members.wrappedValue {
                    member.newMessageCnt = 0
                }
                do {
                    try context.save()
                }
                catch {
                    print("error writing members: \(error.localizedDescription)")
                }
            }
    }
    
    var btnBack : some View { Button(action: {
          self.presentationMode.wrappedValue.dismiss()
          }) {
            HStack {
                Image(systemName: "chevron.left")
                    .aspectRatio(contentMode: .fit)
                    .font(Font.custom("Avenir-Medium", size: 18))
                    .foregroundColor(.white)
                Text("Back")
                    .font(Font.custom("Avenir-Medium", size: 18))
                    .foregroundColor(.white)
            }
          }
      }
    
}

struct msgTail: Shape {
    
    var mymsg: Bool
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, mymsg ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 25, height: 25))
        return Path(path.cgPath)
    }
    
}

