//
//  ContentView.swift
//  NewsSycret
//
//  Created by Denis Stepanov on 2020/9/1.
//  Copyright © 2020 Denis Stepanov. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

//main
struct ContentView: View {
    @ObservedObject var list = getData()
    
    var body: some View {
        NavigationView{
            List(list.news){i in
                NavigationLink(destination:
                webView(url: i.url)
                    .navigationBarTitle("", displayMode: .inline)){
                    HStack(spacing: 15){
                        VStack(alignment: .leading, spacing: 10){
                            //предпоказ новости - название и описание
                            Text(i.title).fontWeight(.heavy)
                            Text(i.description).lineLimit(2)
                        }
                        
                        //фото не может быть null
                        if i.image != ""{
                            //async загрузка и кэширование фото из новостей (thumbnail)
                            WebImage(url: URL(string: i.image)!, options: .highPriority, context: nil)
                                .resizable()
                                .frame(width: 110, height: 135).cornerRadius(20)
                        }
                    }.padding(.vertical, 15)
                }
            }.navigationBarTitle("Новости")
        }
    }
}

//default init
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//структура типа данных для новостей
struct dataType: Identifiable{
    var id          : String
    var title       : String
    var description : String
    var url         : String
    var image       : String
}

class getData : ObservableObject{
    @Published var news = [dataType]()
    
    init(){
        //api ключ для NewsAPI (попробуйте поменять ru на us или in чтобы получить топ новости из других стран)
        let source = "https://newsapi.org/v2/top-headlines?country=ru&apiKey=3e129cffc3b24a958928d4373054c4b2"
        let url = URL(string: source)!
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: url) {
            (data, _, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            
            //swiftyJSON - легкая обработка JSON файлов
            let json = try! JSON(data: data!)
            
            //проверить request и посмотреть какие новости нам доступны
            //print(json)
            
            //пройтись по всем новостям доступным из файла
            for i in json["articles"]{
                let title = i.1["title"].stringValue
                let description = i.1["description"].stringValue
                let url = i.1["url"].stringValue
                let image = i.1["urlToImage"].stringValue
                let id = i.1["publishedAt"].stringValue
                
                DispatchQueue.main.async {
                    self.news.append(dataType(id: id, title: title, description: description, url: url, image: image))
                }
            }
        }.resume()
    }
}

//помощник webview по загрзки новости внутри приложения
struct webView : UIViewRepresentable{
    var url : String
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
        
    }
}
