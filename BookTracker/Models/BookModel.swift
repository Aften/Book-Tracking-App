//
//  BookModel.swift
//  ClassProject
//
//  Created by Aften.
//

import Foundation
import FirebaseDatabase
import SwiftUI
import Firebase

// Class for book functions
class BookViewModel: ObservableObject {
    @Published var books: [LibraryBook] = []
    
    private var db = Firestore.firestore()
    
    // Function to fetch books from the firebase database
    func fetchBooks() {
        db.collection("books").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No data is present in database")
                return
            }
            
            self.books = documents.compactMap { queryDocumentSnapshot -> LibraryBook? in
                return LibraryBook(snapshot: queryDocumentSnapshot)
            }
        }
    }
    
    // Function to add books to the database.
    func addBook(_ book: LibraryBook) {
        var ref: DocumentReference? = nil
        ref = db.collection("books").addDocument(data: [
            "title": book.title,
            "author": book.author,
            "isbn": book.isbn,
            "description": book.description,
            "imageURL": book.imageURL,
            "isWishlisted": book.isWishlisted,
            "isRead": book.isRead
        ]) { error in
            if let error = error {
                print("Error adding book: \(error.localizedDescription)")
            } else {
                print("Book added with ID: \(ref!.documentID)")
            }
        }
    }
    
    // Function to get the details of the book using Google books API, parses dating using JSON parsing.
    func fetchBookDetails(isbn: String, ReadValue: Bool, WishListValue: Bool, completion: @escaping (Result<LibraryBook, Error>) -> Void) {
        // Fetches API key
        let apiKey: String
        do {
            apiKey = try Configuration.value(for: "GOOGLEBOOKSAPI_KEY")
        } catch {
            print("An error occurred: \(error)")
            apiKey = ""
        }

        let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)&key=\(apiKey)")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let items = json?["items"] as? [[String: Any]], let item = items.first,
                   let volumeInfo = item["volumeInfo"] as? [String: Any] {
                   
                    let title = volumeInfo["title"] as? String ?? ""
                    let authors = volumeInfo["authors"] as? [String] ?? []
                    let author = authors.first ?? ""
                    let description = volumeInfo["description"] as? String ?? ""
                    let imageURL = (volumeInfo["imageLinks"] as? [String: Any])?["thumbnail"] as? String ?? ""
                    let book = LibraryBook(id: nil, title: title, author: author, isbn: isbn, description: description, imageURL: imageURL, isWishlisted: WishListValue, isRead: ReadValue)
                    
                    completion(.success(book))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON format", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Function to delete books from the library database
    func deleteBook(_ book: LibraryBook) {
        guard let id = book.id else {
            print("Error, book has no valid ID")
            return
        }
        
        db.collection("books").document(id).delete() { error in
            if let error = error {
                print("Error removing book from database: \(error.localizedDescription)")
            } else {
                print("Book successfully removed.")
            }
        }
    }
    
    // Function to delete all books present in the database.
    func deleteAll() {
        db.collection("books").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No books in current database")
                return
            }
            
            for document in documents {
                self.db.collection("books").document(document.documentID).delete() { error in
                    if let error = error {
                        print("Error removing books: \(error.localizedDescription)")
                    } else {
                        print("All books sucessfully removed.")
                    }
                }
            }
        }
    }
    
    
}

// Struct to hold all values found in the JSON from the google books api.
struct LibraryBook: Identifiable {
    var id: String?
    var title: String
    var author: String
    var isbn: String
    var description: String
    var imageURL: String
    var isWishlisted: Bool
    var isRead: Bool
    
    init(id: String? = nil, title: String, author: String, isbn: String, description: String, imageURL: String, isWishlisted: Bool, isRead: Bool) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.description = description
        self.imageURL = imageURL
        self.isWishlisted = isWishlisted
        self.isRead = isRead
    }
    
    init?(id: String? = nil, snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else { return nil }
        guard let title = data["title"] as? String,
              let author = data["author"] as? String,
              let isbn = data["isbn"] as? String,
              let description = data["description"] as? String,
              let imageURL = data["imageURL"] as? String,
              let isWishlisted = data["isWishlisted"] as? Bool,
              let isRead = data["isRead"] as? Bool
        else {
            return nil
        }
        
        self.id = snapshot.documentID
        self.title = title
        self.author = author
        self.isbn = isbn
        self.description = description
        self.imageURL = imageURL
        self.isWishlisted = isWishlisted
        self.isRead = isRead
    }
    
}


