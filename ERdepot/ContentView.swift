//
//  ContentView.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/15.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // 通过 @Environment 读取 viewContext
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.backgroundContext) private var backgroundContext //
    // 使用 @FetchRequest 获取数据
    @FetchRequest(
        entity: Eurofxrefhist.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Eurofxrefhist.date, ascending: true)],
        animation: .default)
    private var exchangeRates: FetchedResults<Eurofxrefhist>
    
    
    var body: some View {
        NavigationView {
            VStack {
                
                if exchangeRates.isEmpty {
                    Text("这里是空的")
                } else {
                    
                    List {
                        ForEach(exchangeRates, id: \.self) { exchangeRate in
                            Text("\(exchangeRate.date ?? Date())")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    // 创建 NSPersistentContainer
    let container = NSPersistentContainer(name: "ExchangeRateDataModel")
    
    // 存储在内存中，防止写入磁盘
    container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    
    // 加载持久化存储
    container.loadPersistentStores { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    //  预加载一些数据进行预览
    let context = container.viewContext
    let sampleData = Eurofxrefhist(context: context)
    sampleData.date = Date()
    sampleData.currencySymbol = "USD"
    sampleData.exchangeRate = 7.0
    
    do {
        try context.save()
    } catch {
        print("Error saving preview data: \(error.localizedDescription)")
    }
    
    return ContentView()
        .environment(\.managedObjectContext,container.viewContext)
        .environment(\.backgroundContext, container.newBackgroundContext())
}
