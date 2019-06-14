//


//  ViewController.swift
//  RestManager
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//


//https://reqres.in/api/users  GET

import UIKit

class ViewController: UIViewController {
    let rest = RestManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersList()
        getNonExistingUser()
        createUser()
    }
    
    func getUsersList() {
        guard let url = URL(string: "https://reqres.in/api/users") else { return }
        
        rest.urlQueryParameters.add(value: "2", forKey: "page")
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if let response = results.response {
                print("\nRequest with HTTP status code", response.httpStatusCode, "\n")
                print("\n\nResponse HTTP Headers:\n")
                for (key, value) in response.headers.allValues() {
                    print(key, value)
                }
            }
            
            if let data = results.data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let userData = try? decoder.decode(UserData.self, from: data) else { return }
                print(userData.description)
            }
        }
    }
    
    func getNonExistingUser() {
        guard let url = URL(string: "https://reqres.in/api/users/100") else { return }
        rest.makeRequest(toURL: url, withHttpMethod: .get) { (results) in
            if let response = results.response {
                if response.httpStatusCode != 200 {
                    print("\nRequest failed with HTTP status code", response.httpStatusCode, "\n")
                }
            }
        }
    }
    
    func createUser() {
        guard let url = URL(string: "https://reqres.in/api/users") else { return }
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.httpBodyParameters.add(value: "John", forKey: "name")
        rest.httpBodyParameters.add(value: "Developer", forKey: "job")
        rest.makeRequest(toURL: url, withHttpMethod: .post) { (results) in
            guard let response = results.response else { return }
            if response.httpStatusCode == 201 {
                guard let data = results.data else { return }
                let decoder = JSONDecoder()
                guard let jobUser = try? decoder.decode(JobUser.self, from: data) else { return }
                print(jobUser.description)
            }
        }
    }
    
    
    
    func uploadSingleFile() {
        let fileURL = Bundle.main.url(forResource: "sampleText", withExtension: "txt")
        let fileInfo = RestManager.FileInfo(withFileURL: fileURL, filename: "sampleText.txt", name: "uploadedFile", mimetype: "text/plain")
        
        rest.httpBodyParameters.add(value: "Hello 😀 !!!", forKey: "greeting")
        rest.httpBodyParameters.add(value: "AppCoda", forKey: "user")
        
        upload(files: [fileInfo], toURL: URL(string: "http://localhost:3000/upload"))
    }
    
    func uploadMultipleFiles() {
        let textFileURL = Bundle.main.url(forResource: "sampleText", withExtension: "txt")
        let textFileInfo = RestManager.FileInfo(withFileURL: textFileURL, filename: "sampleText.txt", name: "uploadedFile", mimetype: "text/plain")
        
        let pdfFileURL = Bundle.main.url(forResource: "samplePDF", withExtension: "pdf")
        let pdfFileInfo = RestManager.FileInfo(withFileURL: pdfFileURL, filename: "samplePDF.pdf", name: "uploadedFile", mimetype: "application/pdf")
        
        let imageFileURL = Bundle.main.url(forResource: "sampleImage", withExtension: "jpg")
        let imageFileInfo = RestManager.FileInfo(withFileURL: imageFileURL, filename: "sampleImage.jpg", name: "uploadedFile", mimetype: "image/jpg")
        
        upload(files: [textFileInfo, pdfFileInfo, imageFileInfo], toURL: URL(string: "http://localhost:3000/multiupload"))
    }
    
    func upload(files: [RestManager.FileInfo], toURL url: URL?) {
        if let uploadURL = url {
            rest.upload(files: files, toURL: uploadURL, withHttpMethod: .post) { (results, failedFilesList) in
                print("HTTP status code:", results.response?.httpStatusCode ?? 0)
                
                if let error = results.error {
                    print(error)
                }
                
                if let data = results.data {
                    if let toDictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                        print(toDictionary)
                    }
                }
                
                if let failedFiles = failedFilesList {
                    for file in failedFiles {
                        print(file)
                    }
                }
            }
        }
    }
}

