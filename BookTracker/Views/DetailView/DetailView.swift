//
//  DetailView.swift
//  ClassProject
//
//  Created by Aften.
//

import SwiftUI
import Foundation

// Class to showcase the detail view of the table view.
struct DetailView: View {
    var book: LibraryBook
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        if let url = URL(string: book.imageURL) {
                            AsyncImage(url: url, content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }, placeholder: {
                                ProgressView()
                            })
                            .frame(width: 200, height: 300)
                            .cornerRadius(10)
                        }
                        Spacer()
                    }
                    
                    Text(book.title)
                        .font(.title)
                        .bold()
                    
                    Text("Author: \(book.author)")
                        .font(.headline)
                    
                    Text("ISBN: \(book.isbn)")
                        .font(.headline)
                    
                    Text(book.description)
                        .font(.body)
                }
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("Book Details")
    }
}
