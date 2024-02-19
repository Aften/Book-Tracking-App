//
//  HomeView.swift
//  ClassProject
//
//  Created by Aften.
//

import SwiftUI
import CoreData

struct HomeView: View {
    // Objects to handle data
    @ObservedObject var homeModel = NavigationModel()
    @EnvironmentObject var bookViewModelObj: BookViewModel
    
    // Variables for UI Functionality.
    @State private var showingSheet = false
    @State private var isbnInput = ""
    @State private var isReadSelection = false
    @State private var selectedBook: LibraryBook? = nil
    @State private var selectedTab: String = "Read"
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let isWishListSelection = false
    
    private var backgroundName: String {
        return selectedTab == "Read" ? "LibraryRead" : "LibraryUnRead"
    }
    
    var body: some View {
        ZStack {
            Image(backgroundName)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 10) {
                    Button(action: {
                        selectedTab = "Read"
                    }) {
                        Text("Read but")
                            .padding()
                            .opacity(0)
                    }
                    
                    Button(action: {
                        selectedTab = "Unread"
                    }) {
                        Text("UnreadBu")
                        
                            .padding()
                            .opacity(0)
                    }
                    
                    Button(action: {
                        showingSheet = true
                    }) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .opacity(0)
                    }
                    .offset(y:-50)
                    .offset(x:56)
                }
                .onAppear{
                    bookViewModelObj.fetchBooks()
                    
                }
                .padding(.top, 115)
                // Table view for books, filter by either read or unread.
                List {
                    ForEach(bookViewModelObj.books.filter {
                        if selectedTab == "Read" {
                            return $0.isRead
                        } else if selectedTab == "Unread" {
                            return !$0.isRead && !$0.isWishlisted
                        } else {
                            return false
                        }
                    }){ book in
                        NavigationLink(destination: DetailView(book: book)) {
                            HStack {
                                if let url = URL(string: book.imageURL), !book.imageURL.isEmpty {
                                    AsyncImage(url: url, content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }, placeholder: {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(.gray)
                                            .frame(width: 50, height: 75)
                                    })
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(5)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 75)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(book.title)
                                        .font(.headline)
                                    
                                    Text(book.author)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let bookToDelete = bookViewModelObj.books.filter {
                                if selectedTab == "Read" {
                                    return $0.isRead
                                } else if selectedTab == "Unread" {
                                    return !$0.isRead && !$0.isWishlisted
                                } else {
                                    return false
                                }
                            }[index]
                            if let bookIndex = bookViewModelObj.books.firstIndex(where: { $0.id == bookToDelete.id }) {
                                let book = bookViewModelObj.books[bookIndex]
                                bookViewModelObj.deleteBook(book)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, 45)
                .padding(.bottom, 10)
                
                .sheet(isPresented: $showingSheet) {
                    VStack {
                        Text("Add Book")
                            .font(.headline)
                        
                        TextField("Enter ISBN-10 of book", text: $isbnInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Toggle("Read", isOn: $isReadSelection)
                            .padding()
                            .onChange(of: isReadSelection) { value in
                                
                            }
                        // Custom add pop up to get isbn from user and whether or not the book is read or not.
                        Button("Add") {
                            if !isbnInput.isEmpty {
                                bookViewModelObj.fetchBookDetails(isbn: isbnInput, ReadValue: isReadSelection, WishListValue: isWishListSelection) { result in
                                    switch result {
                                    case .success(let book):
                                        DispatchQueue.main.async {
                                            bookViewModelObj.addBook(book)
                                            showingSheet = false
                                        }
                                    case .failure(let error):
                                        print("Error fetching book details: \(error)")
                                        DispatchQueue.main.async {
                                            showAlert = true
                                            alertMessage = "Incorrect ISBN, book failed to add to the list"
                                        }
                                    }
                                }
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        
                    }
                    .padding()
                }
                // Hstack of buttons to handle view navigation.
                HStack(spacing: 10) {
                    Button(action: {
                        homeModel.showHomeView.toggle()
                    }) {
                        Text("Button 1")
                            .padding()
                            .opacity(0)
                    }
                    
                    Button(action: {
                        homeModel.showMapView.toggle()
                    }) {
                        Text("Button 2")
                            .padding()
                            .opacity(0)
                    }
                    
                    Button(action: {
                        homeModel.showSettingsView.toggle()
                    }) {
                        Text("Button 3")
                            .padding()
                            .opacity(0)
                    }
                }
                .padding(.bottom, 30)
            }
            // Function to iterate and determine view state
            ForEach(homeModel.views) { viewState in
                if viewState.isVisible {
                    viewState.view
                }
            }
        }
    }
}


