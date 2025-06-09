//
//  SingleStockIndicesView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/6/9.
//

import SwiftUI
import CoreData

//struct SingleStockIndicesView: View {
//    // 通过 @Environment 读取 viewContext
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.colorScheme) var color
//    @EnvironmentObject var appStorage: AppStorageManager
//    
//    
//    
//    var body: some View {
//        
//        GeometryReader { geo in
//            let width = geo.frame(in: .local).width * 0.95
//            let height = geo.frame(in: .local).height
//            
//            ScrollView {
//                
//            }
//            .frame(width: width * 0.85)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
//    }
//}
//
//#Preview {
//    SingleStockIndicesView()
//        .environmentObject(AppStorageManager.shared)
//        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
//        .environmentObject(YahooManager.shared)
//}
