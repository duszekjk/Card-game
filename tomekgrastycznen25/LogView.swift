//
//  LogView.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 21/01/2025.
//


import SwiftUI

struct LogView: View {
    @ObservedObject var logger = Logger.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(logger.logs, id: \.self) { log in
                    Text(log)
                        .padding(.vertical, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
    }
}
