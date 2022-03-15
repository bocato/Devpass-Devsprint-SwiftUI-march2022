import SwiftUI

struct LaunchCard: View {
    struct Model {
        let id: String
        let imageURL: String
        let flightNumber: Int
        let name: String
        let date: String
        let success: Bool
    }
    
    private let model: Model
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
        HStack {
            RemoteImage(url: model.imageURL)
                .frame(
                    width: DS.Size.xLarge.width,
                    height: .infinity
                )
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("#\(model.flightNumber)")
                        .dsTypography(.body, color: .secondary)
                        .lineLimit(nil)
                }
                VStack(
                    alignment: .leading,
                    spacing: .dsSpacing(.micro)
                ) {
                    Text(model.name)
                        .dsTypography(.headline, color: .primary)
                    Text(model.date)
                        .dsTypography(.body, color: .secondary)
                    Text(model.success ? "Success" : "Failure")
                        .dsTypography(.body, color: .secondary)
                }
            }
            Spacer()
        }
        .padding(.all, .dsSpacing(.small))
        .background(Color.ds(.background))
        .dsCornerRadius(.small)
        .overlay(
            RoundedRectangle(cornerRadius: .dsCornerRadius(.small))
                .stroke(
                    Color.ds(.background),
                    lineWidth: 1
                )
        )
    }
}

extension LaunchCard.Model {
    init(_ launch: Launch) {
        self.init(
            id: launch.id,
            imageURL: launch.links.patch.small ?? "",
            flightNumber: launch.flightNumber,
            name: launch.name,
            date: "July 03, 2020", // TODO: FORMAT DATE
            success: launch.success ?? false
        )
    }
}


#if DEBUG
extension LaunchCard.Model {
    static func fixture(
        id: String = "id",
        imageURL: String = "www.mock.com/image.jpg",
        flightNumber: Int = 91,
        name: String = "CRS-20",
        date: String = "July 03, 2020",
        success: Bool = true
    ) -> Self {
        .init(
            id: id,
            imageURL: imageURL,
            flightNumber: flightNumber, name: name,
            date: date,
            success: success
        )
    }
}

struct LaunchCard_Previews: PreviewProvider {
    static var previews: some View {
        LaunchCard(
            model: .fixture()
        )
        
            .preferredColorScheme(.dark)
        
        LaunchCard(
            model: .fixture()
        )
            .preferredColorScheme(.light)
    }
}
#endif


//
//  ErrorView.swift
//  SpaceApp
//
//  Created by Elena Diniz on 3/10/22.
//

import SwiftUI

struct ErrorView2: View {
    private let title: String
    private let subtitle: String
    private let dismissAction: (() -> Void)?
    
    init(
        title: String,
        subtitle: String,
        dismissAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "exclamationmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200, alignment: .center)
                .clipShape(Circle())
            
            Text(title)
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Button(action: {
                guard let dismissAction = dismissAction else {
                    return
                }
                dismissAction()
            },
                   label: {
                Text("OK")
                    .bold()
                    .frame(width: 200, height: 48)
                    .foregroundColor(Color.white)
                    .background(Color.gray)
                    .cornerRadius(5)
            })
        }
        .padding()
    }
}

struct ErrorView2_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView2(
            title: "Title",
            subtitle: "Put your substitle here!",
            dismissAction: {}
        )
    }
}
